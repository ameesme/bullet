//
//  TaskListView.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TaskItem]
    @Query private var categories: [CategoryItem]

    @State private var inputText: String = ""
    @State private var isFilterPresented: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    @State private var showDead: Bool = false
    @State private var selectedCategoryNames: Set<String> = []

    @State private var sortKey: FilterMenuButton.SortKey = .deadline
    @State private var sortOrder: FilterMenuButton.SortOrder = .ascending

    @State private var selectedItem: TaskItem?

    private var filteredItems: [TaskItem] {
        var base = showDead ? items.filter { !$0.isAlive } : items.filter { $0.isAlive }

        if !selectedCategoryNames.isEmpty {
            base = base.filter { task in
                if let name = task.category?.name {
                    return selectedCategoryNames.contains(name)
                }
                return false
            }
        }

        return base.sorted { lhs, rhs in
            switch sortKey {
            case .age:
                // Sort by creation date - older tasks first in ascending
                return sortOrder == .ascending
                    ? lhs.creationDate < rhs.creationDate  // oldest first
                    : lhs.creationDate > rhs.creationDate  // newest first
            case .deadline:
                return sortOrder == .ascending
                    ? lhs.deadlineDate < rhs.deadlineDate  // soonest first
                    : lhs.deadlineDate > rhs.deadlineDate  // latest first
            }
        }
    }

    private var headerTitle: String {
        showDead ? "Dead" : "Living"
    }

    var body: some View {
        NavigationSplitView {
            ZStack(alignment: .top) {
                List {
                    Color.clear
                        .frame(height: DesignSystem.Layout.listRowHeight)
                        .listRowSeparator(.hidden)

                    ForEach(filteredItems) { item in
                        TaskRowView(
                            item: item,
                            showDead: showDead,
                            sortKey: sortKey,
                            modelContext: modelContext
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
                    }
                }
                .listStyle(.plain)

                if filteredItems.isEmpty {
                    EmptyStateView(
                        isShowingDead: showDead,
                        hasCategoryFilter: !selectedCategoryNames.isEmpty,
                        clearFiltersAction: {
                            selectedCategoryNames.removeAll()
                        }
                    )
                    .padding(.horizontal, DesignSystem.Spacing.extraLarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                GeometryReader { geo in
                    let topInset = geo.safeAreaInsets.top + DesignSystem.Layout.safeAreaTopOffset

                    VStack(spacing: 0) {
                        HeaderView(title: headerTitle, isShowingDead: $showDead)
                            .padding(.top, topInset)
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .padding(.bottom, DesignSystem.Spacing.extraLarge)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(
                        Color(.systemBackground)
                            .mask(
                                LinearGradient(
                                    stops: DesignSystem.Gradient.headerMaskStops,
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
                        .padding(.horizontal, DesignSystem.Spacing.medium + DesignSystem.Spacing.small)
                        .contentShape(Rectangle())

                        Spacer()

                        FilterMenuButton(
                            categories: categories,
                            selectedCategoryNames: $selectedCategoryNames,
                            sortKey: $sortKey,
                            sortOrder: $sortOrder
                        )
                    } else {
                        FilterMenuButton(
                            categories: categories,
                            selectedCategoryNames: $selectedCategoryNames,
                            sortKey: $sortKey,
                            sortOrder: $sortOrder
                        )
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                TaskDetailSheet(item: item)
            }
        } detail: {
            Text("Select an item")
                .foregroundStyle(.secondary)
        }
        .preferredColorScheme(showDead ? .dark : .light)
        .onChange(of: showDead) { oldValue, newValue in
            if newValue {
                // Switching to dead mode
                sortKey = .age
                sortOrder = .ascending
            } else {
                // Switching to living mode
                sortKey = .deadline
                sortOrder = .ascending
            }
        }
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
}

// MARK: - Task Row
private struct TaskRowView: View {
    let item: TaskItem
    let showDead: Bool
    let sortKey: FilterMenuButton.SortKey
    let modelContext: ModelContext

    private var timeText: String {
        let now = Date()
        let isPast = item.deadlineDate < now

        if showDead {
            // Dead tasks
            if sortKey == .age {
                return DateFormatters.formattedLifespan(item.lifespan)
            } else {
                // Deadline sort - show when they died
                if isPast {
                    return "Dead for \(DateFormatters.relativeTime(from: item.deadlineDate))"
                } else {
                    return DateFormatters.formattedLifespan(item.lifespan)
                }
            }
        } else {
            // Living tasks
            if sortKey == .age {
                return "Alive for \(DateFormatters.relativeTime(from: item.creationDate))"
            } else {
                // Deadline sort
                if isPast {
                    return "Dead for \(DateFormatters.relativeTime(from: item.deadlineDate))"
                } else {
                    return DateFormatters.relativeDeadline(from: item.deadlineDate)
                }
            }
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                CategoryDotView(category: item.category)
                Text(item.title)
                    .lineLimit(1, reservesSpace: false)
            }

            Spacer(minLength: DesignSystem.Spacing.medium)

            Text(timeText)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.small)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if showDead {
                Button {
                    withAnimation {
                        item.revive()
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.medium - 2) {
                        Image(systemName: "arrow.uturn.left")
                        Text("Revive")
                    }
                }

                Button(role: .destructive) {
                    withAnimation {
                        modelContext.delete(item)
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.medium - 2) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                }
            } else {
                Button {
                    withAnimation {
                        item.markDead()
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.medium - 2) {
                        Image(systemName: "xmark")
                        Text("Kill")
                    }
                }
                .tint(.black)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: TaskItem.self, CategoryItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let palette = CategoryItem.accentPalette
    var categories: [CategoryItem] = []
    for i in 0..<5 {
        let colorName = i < palette.count ? palette[i] : palette.randomElement()
        let category = CategoryItem(name: "Category \(i + 1)", colorName: colorName)
        categories.append(category)
        container.mainContext.insert(category)
    }

    let now = Date()
    let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now.addingTimeInterval(-60 * 60 * 24 * 60)
    let threeMonthsInSeconds: TimeInterval = 60 * 60 * 24 * 90
    let oneHourInSeconds: TimeInterval = 60 * 60

    for i in 0...5 {
        // Random creation date in [twoMonthsAgo, now]
        let creationInterval = now.timeIntervalSince(twoMonthsAgo)
        let randomOffsetFromTwoMonthsAgo = TimeInterval.random(in: 0...creationInterval)
        let created = twoMonthsAgo.addingTimeInterval(randomOffsetFromTwoMonthsAgo)

        // Random deadline offset in [1 hour, 3 months]
        let deadlineOffset = TimeInterval.random(in: oneHourInSeconds...threeMonthsInSeconds)
        let deadline = created.addingTimeInterval(deadlineOffset)

        let task = TaskItem(
            title: "Task \(i)",
            creationDate: created,
            deadlineDate: deadline,
            category: categories.randomElement()
        )
        container.mainContext.insert(task)
    }

    return TaskListView()
        .modelContainer(container)
}
