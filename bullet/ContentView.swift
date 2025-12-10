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

    // Sorting state
    enum SortKey: String, CaseIterable {
        case age
        case deadline
    }
    enum SortOrder {
        case ascending
        case descending
    }
    @State private var sortKey: SortKey = .deadline
    @State private var sortOrder: SortOrder = .ascending

    // Sheet selection
    @State private var selectedItem: TaskItem?

    private var filteredItems: [TaskItem] {
        // Base alive/dead filter
        var base = showDead ? items.filter { !$0.isAlive } : items.filter { $0.isAlive }

        // Category filter (only when some selected)
        if !selectedCategoryNames.isEmpty {
            base = base.filter { task in
                if let name = task.category?.name {
                    return selectedCategoryNames.contains(name)
                }
                return false
            }
        }

        // Sorting
        base.sort { lhs, rhs in
            switch sortKey {
            case .age:
                let l = lhs.deadlineDate.timeIntervalSince(lhs.creationDate)
                let r = rhs.deadlineDate.timeIntervalSince(rhs.creationDate)
                return sortOrder == .ascending ? (l < r) : (l > r)
            case .deadline:
                let l = lhs.deadlineDate
                let r = rhs.deadlineDate
                return sortOrder == .ascending ? (l < r) : (l > r)
            }
        }

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
                        HStack(spacing: 8) {
                            // Leading: colored dot + title
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(item.category?.color ?? .secondary)
                                    .font(.system(size: 8))

                                Text(item.title)
                                    .lineLimit(1, reservesSpace: false)
                            }

                            Spacer(minLength: 8)

                            // Trailing: time string (computed inline)
                            Text(showDead ? formattedLifespan(item.lifespan) : relativeDeadline(from: item.deadlineDate))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
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

                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(item)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash")
                                        Text("Delete")
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

                // Empty state overlay
                if filteredItems.isEmpty {
                    EmptyStateView(
                        isShowingDead: showDead,
                        hasCategoryFilter: !selectedCategoryNames.isEmpty,
                        clearFiltersAction: {
                            selectedCategoryNames.removeAll()
                        }
                    )
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

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
                DetailSheet(item: item)
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

    // MARK: - Formatting helpers
    private func relativeDeadline(from deadline: Date) -> String {
        let now = Date()
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .hour, .day, .weekOfYear]
        f.unitsStyle = .full
        f.maximumUnitCount = 2

        // Use the (from:to:) overload to get a relative description
        let raw = f.string(from: now, to: deadline) ?? ""

        // Remove leading "in "
        var text = raw
        if text.hasPrefix("in ") {
            text.removeFirst(3)
        }

        // Prefix for future deadlines
        if deadline > now {
            return "Dead in \(text)"
        } else {
            return text
        }
    }

    private func formattedLifespan(_ interval: TimeInterval) -> String {
        let f = DateComponentsFormatter()
        f.unitsStyle = .full
        f.allowedUnits = [.year, .month, .weekOfYear, .day, .hour, .minute]
        f.maximumUnitCount = 2
        return "Lived for \(f.string(from: interval) ?? "")"
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

// MARK: - Filter menu button with sorting and category multi-select
private struct FilterMenuButton: View {
    let categories: [CategoryItem]
    @Binding var selectedCategoryNames: Set<String>
    @Binding var sortKey: ContentView.SortKey
    @Binding var sortOrder: ContentView.SortOrder

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
                    
                    Button {
                        sortKey = .age
                        sortOrder = .descending
                    } label: {
                        HStack {
                            Text("Descending")
                            if sortKey == .age && sortOrder == .descending {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        sortKey = .age
                        sortOrder = .ascending
                    } label: {
                        HStack {
                            Text("Ascending")
                            if sortKey == .age && sortOrder == .ascending {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Menu("Deadline") {
                    Button {
                        sortKey = .deadline
                        sortOrder = .descending
                    } label: {
                        HStack {
                            Text("Descending")
                            if sortKey == .deadline && sortOrder == .descending {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        sortKey = .deadline
                        sortOrder = .ascending
                    } label: {
                        HStack {
                            Text("Ascending")
                            if sortKey == .deadline && sortOrder == .ascending {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .imageScale(.large)
        }
        .accessibilityLabel("Filter")
    }
}

// MARK: - Living/Dead dynamic-color animated toggle (simple)
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

private struct DetailSheet: View {
    let item: TaskItem

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    InfoRow(
                        title: "Category",
                        valueView: AnyView(
                            HStack(spacing: 6) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(item.category?.color ?? .secondary)
                                    .font(.system(size: 8))
                                Text(item.category?.name ?? "None")
                            }
                        )
                    )
                    Divider()
                    InfoRow(
                        title: "Age",
                        value: formattedAge(from: item.creationDate)
                    )
                    Divider()
                    InfoRow(
                        title: "Deadline",
                        value: formattedDate(item.deadlineDate)
                    )
                    Divider()

                    // Rich text section
                    VStack(spacing: 8) {
                        if item.richText.characters.isEmpty {
                            Text("No notes")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            // AttributedString renders directly with Text
                            Text(item.richText)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 16)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle(item.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { }
                        .disabled(true)
                }
            }
        }
    }

    private func formattedAge(from start: Date) -> String {
        let now = Date()
        let f = DateComponentsFormatter()
        f.unitsStyle = .full
        f.allowedUnits = [.year, .month, .weekOfYear, .day, .hour, .minute]
        f.maximumUnitCount = 2
        return f.string(from: start, to: now) ?? ""
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

private struct InfoRow: View {
    let title: String
    var value: String?
    var valueView: AnyView?

    init(title: String, value: String) {
        self.title = title
               self.value = value
        self.valueView = nil
    }

    init(title: String, valueView: AnyView) {
        self.title = title
        self.valueView = valueView
        self.value = nil
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let valueView {
                valueView
            } else if let value {
                Text(value)
            }
        }
        .font(.body)
        .foregroundStyle(.secondary)
        .frame(minHeight: 44)
    }
}

private struct EmptyStateView: View {
    let isShowingDead: Bool
    let hasCategoryFilter: Bool
    let clearFiltersAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if isShowingDead {
                Image(isShowingDead ? "cemetary.empty" : "cemetary")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
            } else {
                Image(isShowingDead ? "cemetary.empty" : "cemetary")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
            }
            

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

            }

            HStack(spacing: 12) {
                if hasCategoryFilter {
                    Button {
                        clearFiltersAction()
                    } label: {
                        Label("Clear filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: 480)
        .accessibilityElement(children: .contain)
    }

    private var title: String {
        if hasCategoryFilter {
            return "Nothing found for these categories."
        } else {
            return isShowingDead ? "Nothing's dead (yet)" : "Everything's dead"
        }
    }
    private var message: String {
        if hasCategoryFilter {
            return ""
        }
        
        return isShowingDead ? "Why?" : "You killed it."
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

    let now = Date()
    let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now.addingTimeInterval(-60 * 60 * 24 * 60)
    let threeMonthsInSeconds: TimeInterval = 60 * 60 * 24 * 90
    let oneHourInSeconds: TimeInterval = 60 * 60

    for i in 0...0 {
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
            category: categories.randomElement(),
        )
        container.mainContext.insert(task)
    }

    return ContentView()
        .modelContainer(container)
}
