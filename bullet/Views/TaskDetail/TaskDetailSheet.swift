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

    @State private var isEditing: Bool = false
    @Query private var categories: [CategoryItem]
    @State private var selectedCategory: CategoryItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
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
                                                if selectedCategory?.name == category.name {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: DesignSystem.Spacing.medium - 2) {
                                        CategoryDotView(category: selectedCategory)
                                        Text(selectedCategory?.name ?? "None")
                                            .foregroundStyle(.tertiary)
                                    }
                                    .foregroundStyle(.secondary)
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
                    InfoRow(
                        title: "Age",
                        value: DateFormatters.formattedAge(from: item.creationDate)
                    )
                    Divider()
                    InfoRow(
                        title: "Deadline",
                        value: DateFormatters.formattedDate(item.deadlineDate)
                    )
                    Divider()

                    // Notes section
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
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
            .navigationTitle(item.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button {
                            confirmChanges()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Button("Edit") {
                            withAnimation {
                                selectedCategory = item.category
                                isEditing = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func confirmChanges() {
        item.category = selectedCategory
        withAnimation {
            isEditing = false
        }
    }
}
