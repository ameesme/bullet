import SwiftUI
import SwiftData
import UIKit

enum World {
    case alive
    case graveyard
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var newTitle: String = ""
    @State private var newNotes: String = ""
    @State private var world: World = .alive
    @State private var now: Date = .now

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var aliveTasks: [TaskItem] {
        tasks.filter { !$0.isDead(referenceDate: now) }
    }

    var deadTasks: [TaskItem] {
        tasks.filter { $0.isDead(referenceDate: now) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 20)

                if world == .alive {
                    aliveList
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    graveyardList
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.bottom, world == .alive ? 90 : 20)

            if world == .alive {
                AddTaskBar(newTitle: $newTitle, newNotes: $newNotes, addAction: addTask)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom))
            }
        }
        .onReceive(timer) { date in
            now = date
        }
        .animation(.easeInOut, value: world)
        .animation(.linear(duration: 0.2), value: tasks.count)
    }

    private var background: some View {
        LinearGradient(colors: world == .alive ? [.white, Color(UIColor.systemGray6)] : [Color.black, Color.black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            .overlay(world == .graveyard ? Color.black.opacity(0.3) : Color.clear)
            .animation(.easeInOut(duration: 0.5), value: world)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(world == .alive ? "Alive" : "Graveyard")
                    .font(.largeTitle.bold())
                Text(world == .alive ? "Tasks that still breathe" : "Where finished and forgotten tasks rest")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: toggleWorld) {
                Label(world == .alive ? "Graveyard" : "Alive", systemImage: world == .alive ? "arrow.down.circle" : "arrow.up.circle")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .symbolEffect(.bounce, value: world)
            }
            .buttonStyle(.plain)
            .padding(12)
            .background(.ultraThinMaterial, in: Circle())
        }
    }

    private var aliveList: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(aliveTasks) { task in
                        TaskRow(task: task, now: now, reviveAction: { revive(task) }, killAction: { kill(task) })
                            .padding(.horizontal)
                            .transition(.opacity)
                    }

                    GraveyardHint()
                        .padding(.horizontal)
                        .background(
                            GeometryReader { bottomProxy in
                                Color.clear.preference(key: BottomOffsetKey.self, value: bottomProxy.frame(in: .named("aliveScroll")).maxY - proxy.size.height)
                            }
                        )
                }
                .padding(.vertical, 16)
            }
            .coordinateSpace(name: "aliveScroll")
            .onPreferenceChange(BottomOffsetKey.self) { offset in
                let threshold: CGFloat = 10
                if offset <= threshold && world == .alive {
                    popToGraveyard()
                }
            }
        }
    }

    private var graveyardList: some View {
        ScrollView {
            VStack(spacing: 16) {
                if deadTasks.isEmpty {
                    Text("No fallen tasks yet.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 40)
                }

                ForEach(deadTasks) { task in
                    GraveyardRow(task: task)
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.vertical, 16)
        }
    }

    private func addTask() {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let newTask = TaskItem(title: trimmedTitle, notes: newNotes.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(newTask)
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        newTitle = ""
        newNotes = ""
    }

    private func revive(_ task: TaskItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            task.revive(now: now)
        }
    }

    private func kill(_ task: TaskItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            task.kill(now: now)
        }
    }

    private func delete(_ task: TaskItem) {
        withAnimation {
            modelContext.delete(task)
        }
    }

    private func toggleWorld() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            world = world == .alive ? .graveyard : .alive
        }
    }

    private func popToGraveyard() {
        toggleWorld()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.9)
    }
}

private struct BottomOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TaskRow: View {
    let task: TaskItem
    let now: Date
    let reviveAction: () -> Void
    let killAction: () -> Void

    var body: some View {
        let progress = task.decayProgress(referenceDate: now)
        let blurRadius = progress * 6

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .blur(radius: blurRadius)
                        .opacity(1 - (progress * 0.4))
                    if !task.notes.isEmpty {
                        Text(task.notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .blur(radius: blurRadius / 2)
                            .opacity(1 - (progress * 0.4))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    ProgressView(value: min(max(progress, 0), 1))
                        .progressViewStyle(.linear)
                        .tint(.primary)
                    Text(task.expiryDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 6)
        .swipeActions(edge: .leading) {
            Button(action: reviveAction) {
                Label("Revive", systemImage: "heart.fill")
            }
            .tint(.green)
        }
        .swipeActions {
            Button(role: .destructive, action: killAction) {
                Label("Kill", systemImage: "xmark")
            }
        }
    }
}

struct GraveyardRow: View {
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title)
                .font(.headline)
                .foregroundStyle(.white)
            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            HStack {
                Image(systemName: "hourglass.bottomhalf.filled")
                Text(task.expiryDate, style: .relative)
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1))
        )
    }
}

struct GraveyardHint: View {
    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 60, height: 6)
            Text("Scroll to descend into the graveyard")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct AddTaskBar: View {
    @Binding var newTitle: String
    @Binding var newNotes: String
    let addAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            TextField("Task title", text: $newTitle)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .frame(height: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .submitLabel(.done)
                .onSubmit(addAction)

            TextField("Notes (optional)", text: $newNotes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .frame(height: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .submitLabel(.done)
                .onSubmit(addAction)

            Button(action: addAction) {
                Label("Add Task", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
