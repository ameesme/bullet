//
//  TaskDetailSheet.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI
import SwiftData

struct TaskDetailSheet: View {
    let item: TaskItem

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    @Query private var categories: [CategoryItem]
    @State private var selectedCategory: CategoryItem?
    @State private var showNewCategoryAlert: Bool = false
    @State private var newCategoryName: String = ""
    @State private var selectedDeadline: Date = Date()
    @State private var editedNotes: String = ""
    @State private var editedTitle: String = ""

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Title editor when editing
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .font(.system(size: 34, weight: .bold))
                                .padding(.bottom, DesignSystem.Spacing.large)
                                .id("top")
                        } else {
                            Color.clear.frame(height: 0).id("top")
                        }

                        // Category row: menu when editing, read-only otherwise
                    if isEditing {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            HStack {
                                Text("Category")
                                Spacer()

                                Menu {
                                    Button {
                                        selectedCategory = nil
                                    } label: {
                                        HStack {
                                            Text("None")
                                            if selectedCategory == nil {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }

                                    // Categories
                                    ForEach(categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            HStack {
                                                CategoryDotView(
                                                    category: category,
                                                    size: DesignSystem.IconSize.tiny
                                                )
                                                Text(category.name)
                                            }
                                        }
                                    }

                                    Divider()

                                    Button {
                                        showNewCategoryAlert = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle")
                                            Text("New Category...")
                                        }
                                    }
                                } label: {
                                    HStack(spacing: DesignSystem.Spacing.medium - 2) {
                                        CategoryDotView(category: selectedCategory)
                                        Text(selectedCategory?.name ?? "None")
                                            .foregroundStyle(.primary)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .menuStyle(.automatic)
                            }
                            .frame(minHeight: DesignSystem.Layout.minRowHeight)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }
                    } else {
                        InfoRow(
                            title: "Category",
                            valueView: AnyView(
                                HStack(spacing: DesignSystem.Spacing.medium - 2) {
                                    CategoryDotView(category: item.category)
                                    Text(item.category?.name ?? "None")
                                }
                            )
                        )
                    }

                    Divider()

                    // Deadline row: date picker when editing, read-only otherwise
                    if isEditing {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            HStack {
                                Text("Deadline")
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $selectedDeadline,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .labelsHidden()
                            }
                            .frame(minHeight: DesignSystem.Layout.minRowHeight)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }
                    } else {
                        InfoRow(
                            title: "Deadline",
                            value: DateFormatters.formattedDeadline(item.deadlineDate)
                        )
                    }

                    Divider()
                    InfoRow(
                        title: "Age",
                        value: DateFormatters.formattedAge(from: item.creationDate)
                    )

                    if !item.isAlive {
                        Divider()
                        InfoRow(
                            title: "Lifetime",
                            value: DateFormatters.formattedLifetime(item.lifetime)
                        )
                    }

                    Divider()

                    // Notes section
                    if isEditing {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $editedNotes)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, -4)
                                .padding(.vertical, -8)

                            if editedNotes.isEmpty {
                                Text("Notes")
                                    .foregroundStyle(.secondary)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(minHeight: 300)
                        .padding(.top, DesignSystem.Spacing.large)
                    } else {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            if item.notes.isEmpty {
                                Text("No notes")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text(item.notes)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.large)

                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, -DesignSystem.Spacing.medium)
                .onChange(of: isEditing) { _, newValue in
                    if !newValue {
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
            }
            .navigationTitle(isEditing ? "" : item.title)
            .navigationBarTitleDisplayMode(isEditing ? .inline : .large)
            .presentationDragIndicator(isEditing ? .hidden : .visible)
            .interactiveDismissDisabled(isEditing)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if item.isAlive {
                        if isEditing {
                            Button("Done") {
                                confirmChanges()
                            }
                            .fontWeight(.semibold)
                            .tint(.black)
                        } else {
                            Button("Edit") {
                                withAnimation {
                                    selectedCategory = item.category
                                    selectedDeadline = item.deadlineDate
                                    editedNotes = item.notes
                                    editedTitle = item.title
                                    isEditing = true
                                }
                                // Hack to force TextEditor to refresh and show all content
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    editedNotes.append(" ")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        if editedNotes.hasSuffix(" ") {
                                            editedNotes.removeLast()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()

                    Button(role: .destructive) {
                        withAnimation {
                            modelContext.delete(item)
                        }
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .alert("New Category", isPresented: $showNewCategoryAlert) {
                TextField("Category name", text: $newCategoryName)
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Create") {
                    createNewCategory()
                }
            } message: {
                Text("Enter a name for the new category")
            }
        }
    }

    private func confirmChanges() {
        item.title = editedTitle
        item.category = selectedCategory
        item.deadlineDate = selectedDeadline
        item.notes = editedNotes
        withAnimation {
            isEditing = false
        }
    }

    private func createNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            newCategoryName = ""
            return
        }

        // Check if category already exists
        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            newCategoryName = ""
            return
        }

        // Get colors already in use
        let usedColors = Set(categories.compactMap { $0.colorName })

        // Find unused colors
        let unusedColors = CategoryItem.accentPalette.filter { !usedColors.contains($0) }

        // Prefer an unused color, fallback to random if all are used
        let colorToUse = unusedColors.randomElement() ?? CategoryItem.accentPalette.randomElement()

        // Create new category with preferred color
        let newCategory = CategoryItem(name: trimmedName, colorName: colorToUse)
        modelContext.insert(newCategory)

        // Select the newly created category
        selectedCategory = newCategory

        newCategoryName = ""
    }

}
