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

    @State private var inputText: String = ""
    @State private var isFilterPresented: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.title2)
                                .bold()

                            Text("Created: \(item.creationDate, format: Date.FormatStyle(date: .numeric, time: .shortened))")

                            Text("Deadline: \(item.deadlineDate, format: Date.FormatStyle(date: .numeric, time: .shortened))")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            HStack(spacing: 12) {
                                Text(item.creationDate, format: Date.FormatStyle(date: .numeric, time: .shortened))
                                    .foregroundStyle(.secondary)

                                Text(item.deadlineDate, format: Date.FormatStyle(date: .numeric, time: .shortened))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
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

                    if isTextFieldFocused {
                        Button {
                            isTextFieldFocused = false
                            inputText = ""
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                        }
                        .accessibilityLabel("Cancel editing")
                    } else {
                        Button {
                            isFilterPresented = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .imageScale(.large)
                        }
                        .accessibilityLabel("Filter")
                    }
                }
            }
        } detail: {
            Text("Select a task")
        }
        .id(isTextFieldFocused)
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
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskItem.self, CategoryItem.self], inMemory: true)
}
