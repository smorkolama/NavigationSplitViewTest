//
//  ContentView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI

struct ContentView: View {

    enum DetailViewState {
        case selectedItem(Item)
        case none
        case editing
    }

    @State private var model = Model()
    @State private var selection: Set<Item.ID> = []
    @State private var editMode: EditMode = .inactive
    // Always show 2 columns
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                ForEach(model.items, id: \.id) { item in
                    ItemView(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("All items")
            // Make room in detail view for column
            .navigationSplitViewStyle(.balanced)
            // Uncomment if you want to remove the sidebar toggle
            // .toolbar(removing: .sidebarToggle)
            .toolbar {
                EditButton()
            }
            .toolbar {
                // Show 'Delete' button in edit mode
                if editMode == .active {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: deleteSelection) {
                            Label("Delete", systemImage: "trash")
                        }
                        // Disable if nothing is selected
                        .disabled(selection.isEmpty)
                    }
                }
            }
            .onAppear {
                // Auto select first item in list
                selectFirstItem()
            }
            .environment(\.editMode, $editMode) // Bind edit mode
            .onChange(of: editMode) { _, newMode in
                // Detect when edit mode finishes
                if newMode == .inactive {
                    selectFirstItem()
                }
            }
            .onChange(of: selection) { oldValue, newValue in
                print("Selection \(oldValue) -> \(newValue)")
            }
        } detail: {
            switch detailViewState {
            case .selectedItem(let item):
                DetailView(item: item)
            case .none:
                // You won't see this due to auto-selection of first item
                Text("Please select a person")
            case .editing:
                Text("Editing")
                // alternative could be: EmptyView()
            }
        }
    }

    // MARK: - Detail view state

    private var detailViewState: DetailViewState {
        if editMode.isEditing {
            return .editing
        }
        else if let item = model.items.first(where: { $0.id == selection.first }) {
            return .selectedItem(item)
        }

        return .none
    }

    // MARK: - Selection

    private func selectFirstItem() {
        if let firstItem = model.items.first {
            print("Set selection to \(firstItem.id)")
            Task {
                selection = [firstItem.id]
            }
        }
    }

    // MARK: - Delete items

    // Used in swipe to delete
    private func deleteItems(at offsets: IndexSet) {
        // Remove items from selection
        for offset in offsets {
            if let item = model.items[safe: offset] {
                selection.remove(item.id)
            }
        }

        // Remove from list
        model.items.remove(atOffsets: offsets)

        // Check if first item needs to be re-selected
        if editMode != .active && selection.isEmpty {
            selectFirstItem()
        }
    }

    // Used in delete selection button
    private func deleteSelection() {
        // Determine the indexes of selected items
        let offsets = IndexSet(model.items.enumerated().compactMap { index, item in
            selection.contains(item.id) ? index : nil
        })

        // Perform the removal
        deleteItems(at: offsets)
    }
}

#Preview {
    ContentView()
}
