//
//  FilterMenuButton.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct FilterMenuButton: View {
    let categories: [CategoryItem]
    @Binding var selectedCategoryNames: Set<String>
    @Binding var sortKey: SortKey
    @Binding var sortOrder: SortOrder

    enum SortKey: String, CaseIterable {
        case age
        case deadline
    }

    enum SortOrder {
        case ascending
        case descending
    }

    private var isFilterActive: Bool {
        !selectedCategoryNames.isEmpty
    }

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
                                CategoryDotView(category: category)
                                Text(category.name)
                            }
                        }
                    }
                }
            }
            Divider()
            Section("Sort by") {
                Menu {
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
                } label: {
                    HStack {
                        if sortKey == .age {
                            Image(systemName: "checkmark")
                        }
                        Text("Age")
                    }
                }

                Menu {
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
                } label: {
                    HStack {
                        if sortKey == .deadline {
                            Image(systemName: "checkmark")
                        }
                        Text("Deadline")
                    }
                }
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease")
                    .imageScale(.large)

                if isFilterActive {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .accessibilityLabel("Filter")
    }
}
