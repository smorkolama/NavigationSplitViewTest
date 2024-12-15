//
//  ContentView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI


struct Item: Identifiable, Equatable {
    var id: String
    let name: String
    let description: String
}

class Model: ObservableObject {
    @Published var items: [Item] = [
        Item(id: "1", name: "Henkie Test", description: "Really nice guy"),
        Item(id: "2", name: "Some Dude", description: "Really short guy"),
        Item(id: "3", name: "More Guy", description: "Really long guy"),
        Item(id: "4", name: "Another Guy", description: "Really handsome guy"),
        Item(id: "5", name: "Yet Another Guy", description: "Really smart guy"),
    ]
}


struct ItemView: View {
    var item: Item

    var body: some View {
        VStack {
            Text(item.name)
        }
    }
}

struct DetailView: View {
    var item: Item

    var body: some View {
        VStack {
            Text(item.name)
            Text(item.description)
        }
        .navigationTitle("Details for \(item.name)")
    }
}

struct ContentView: View {
    @State private var model = Model()
    @State private var selection: Set<Item.ID> = []
    @State private var editMode: EditMode = .inactive

    init() {
        print("INIT")
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List(selection: $selection) {
                ForEach(model.items, id: \.id) { item in
                    ItemView(item: item)
                }
                .onDelete(perform: removeRows)
            }
            .navigationTitle("People")
            .onAppear {
                // Auto select first item in list
                selectFirstItem()
            }
            .toolbar {
                EditButton()
            }
            .toolbar {
                // Delete selection
                ToolbarItem(placement: .navigationBarTrailing) {
                    if editMode == .active {
                        Button(action: deleteSelection) {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(selection.isEmpty) // Disable if nothing is selected
                    }
                }
            }
            .environment(\.editMode, $editMode) // Bind edit mode
            .onChange(of: editMode) { _, newMode in
                if newMode == .inactive {
                    // Detect when edit mode finishes
                    selectFirstItem()
                }
            }
            .onChange(of: selection) { oldValue, newValue in
                print("Selection \(oldValue) -> \(newValue)")
            }
        } detail: {
            if editMode.isEditing {
                Text("Editing")
//                EmptyView()
            }
            else if let item = model.items.first(where: { $0.id == selection.first }) {
                DetailView(item: item)
            } else {
                Text("Please select a person")
            }
        }
    }

    // Used in swipe to delete
    func removeRows(at offsets: IndexSet) {
        for offset in offsets {
            if let item = model.items[safe: offset] {
                selection.remove(item.id)
            }
        }

        model.items.remove(atOffsets: offsets)

        if editMode != .active && selection.isEmpty {
            selectFirstItem()
        }
    }

    // Used in delete selection button
    func deleteSelection() {
        let selectedIDs = selection
        // Determine the indexes of selected items
        let offsets = IndexSet(model.items.enumerated().compactMap { index, item in
            selectedIDs.contains(item.id) ? index : nil
        })

        // Perform the removal
        removeRows(at: offsets)
    }

    func selectFirstItem() {
        if let firstItem = model.items.first {
            print("Set selection to \(firstItem.id)")
            Task {
                selection = [firstItem.id]
            }
        }
    }
}

#Preview {
    ContentView()
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
