//
//  ContentView.swift
//  bullet
//
//  Created by Mees on 01/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TaskItem]
    @Query private var categories: [CategoryItem]

    @State private var inputText: String = ""
    @State private var isFilterPresented: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    // Toggle between showing living (false) and dead (true) tasks
    @State private var showDead: Bool = false

    // Selected categories by unique name
    @State private var selectedCategoryNames: Set<String> = []

    private var filteredItems: [TaskItem] {
        let base = showDead ? items.filter { !$0.isAlive } : items.filter { $0.isAlive }
        // Category filtering not applied yet.
        return base
    }

    private var headerTitle: String {
        showDead ? "Dead" : "Living"
    }

    var body: some View {
        NavigationSplitView {
            ZStack(alignment: .top) {
                List {
                    Color.clear
                        .frame(height: 48)
                        .listRowSeparator(.hidden)

                    ForEach(filteredItems) { item in
                        Text(item.title)
                            .font(.headline)
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if showDead {
                                    Button {
                                        withAnimation {
                                            item.revive()
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.uturn.left")
                                            Text("Revive")
                                        }
                                    }
                                } else {
                                    Button {
                                        withAnimation {
                                            item.isCompleted = true
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "xmark")
                                            Text("Kill")
                                        }
                                    }
                                    .tint(.black)
                                }
                            }
                    }
                }
                .listStyle(.plain)

                GeometryReader { geo in
                    let topInset = geo.safeAreaInsets.top + 16

                    VStack(spacing: 0) {
                        HeaderView(title: headerTitle, isShowingDead: $showDead)
                            .padding(.top, topInset)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(
                        Color(.systemBackground)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0.0),
                                        .init(color: .black, location: 0.9),
                                        .init(color: .black.opacity(0.0), location: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .ignoresSafeArea(edges: .top)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if !showDead {
                        HStack {
                            TextField("New task...", text: $inputText)
                                .textFieldStyle(.plain)
                                .submitLabel(.done)
                                .focused($isTextFieldFocused)
                                .onSubmit { submitInput() }
                        }
                        .padding(.horizontal, 12)
                        .contentShape(Rectangle())

                        Spacer()

                        FilterMenuButton(
                            categories: categories,
                            selectedCategoryNames: $selectedCategoryNames
                        )
                    } else {
                        FilterMenuButton(
                            categories: categories,
                            selectedCategoryNames: $selectedCategoryNames
                        )
                    }
                }
            }
        } detail: {
            Text("Select an item")
                .foregroundStyle(.secondary)
        }
        .preferredColorScheme(showDead ? .dark : .light)
    }

    private func submitInput() {
        let title = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        withAnimation {
            let newTask = TaskItem(title: title, creationDate: .now)
            modelContext.insert(newTask)
        }
        inputText = ""
        isTextFieldFocused = false
    }

    private func addItem() {
        withAnimation {
            let newTask = TaskItem(
                title: "New Task \(Int.random(in: 1...999))",
                creationDate: .now
            )
            modelContext.insert(newTask)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let task = filteredItems[index]
                if showDead {
                    task.revive()
                } else {
                    task.isCompleted = true
                }
            }
        }
    }
}

private struct HeaderView: View {
    let title: String
    @Binding var isShowingDead: Bool

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.largeTitle).bold()

            Spacer()

            LivingDeadToggle(isOn: $isShowingDead)
                .accessibilityLabel("\(title) toggle")
        }
    }
}

// MARK: - Filter menu button using Section headers with multi-select Toggles and colored dots (sorted)
private struct FilterMenuButton: View {
    let categories: [CategoryItem]
    @Binding var selectedCategoryNames: Set<String>

    var body: some View {
        Menu {
            Section("Categories") {
                if categories.isEmpty {
                    Text("No categories").foregroundStyle(.secondary).disabled(true)
                } else {
                    ForEach(categories.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }), id: \.name) { category in
                        let isOn = Binding<Bool>(
                            get: { selectedCategoryNames.contains(category.name) },
                            set: { newValue in
                                if newValue {
                                    selectedCategoryNames.insert(category.name)
                                } else {
                                    selectedCategoryNames.remove(category.name)
                                }
                            }
                        )
                        Toggle(isOn: isOn) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .tint(category.color)
                                    .font(.system(size: 8))
                                Text(category.name)
                            }
                        }
                    }
                }
            }
            Divider()
            Section("Sort by") {
                Menu("Age") {
                    Text("Ascending").disabled(true)
                    Text("Descending").disabled(true)
                }
                Menu("Deadline") {
                    Text("Ascending").disabled(true)
                    Text("Descending").disabled(true)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .imageScale(.large)
        }
        .accessibilityLabel("Filter")
    }
}

// MARK: - Living/Dead dynamic-color animated toggle
private struct LivingDeadToggle: View {
    @Binding var isOn: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let height: CGFloat = 36
    private let width: CGFloat = 92
    private let padding: CGFloat = 3

    var body: some View {
        let knobHeight = height - padding * 2
        let knobWidth = knobHeight + 20
        let corner = knobHeight / 2
        let foreground = Color(.label)
        let background = Color(.systemBackground)

        Button {
            // Haptic feedback on toggle
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()

            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.1)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(isOn ? foreground : background)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                            .stroke(foreground, lineWidth: 2)
                    )

                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(isOn ? background : foreground)
                    .frame(width: knobWidth, height: knobHeight)
                    .padding(padding)
            }
            .frame(width: width, height: height)
            .contentShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "Dead" : "Living")
    }
}

#Preview {
    let container = try! ModelContainer(for: TaskItem.self, CategoryItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    // Create 5 categories with distinct colors (or random if palette shorter)
    let palette = CategoryItem.accentPalette
    var categories: [CategoryItem] = []
    for i in 0..<5 {
        let colorName = i < palette.count ? palette[i] : palette.randomElement()
        let category = CategoryItem(name: "Category \(i + 1)", colorName: colorName)
        categories.append(category)
        container.mainContext.insert(category)
    }

    // Seed both living and dead tasks, each assigned a random category
    let baseDate = Date()

    for i in 1...10 {
        let created = Calendar.current.date(byAdding: .hour, value: -i, to: baseDate) ?? baseDate
        let deadline = Calendar.current.date(byAdding: .hour, value: 24 + i, to: created) ?? baseDate.addingTimeInterval(24 * 3600)
        let task = TaskItem(
            title: "Task \(i)",
            creationDate: created,
            deadlineDate: deadline,
            category: categories.randomElement()
        )
        container.mainContext.insert(task)
    }

    for i in 1...10 {
        let created = Calendar.current.date(byAdding: .day, value: -(i + 2), to: baseDate) ?? baseDate
        let deadline = Calendar.current.date(byAdding: .hour, value: -1, to: baseDate) ?? baseDate.addingTimeInterval(-3600)
        let task = TaskItem(
            title: "Task \(i + 10)",
            creationDate: created,
            deadlineDate: deadline,
            category: categories.randomElement()
        )
        container.mainContext.insert(task)
    }

    return ContentView()
        .modelContainer(container)
}
