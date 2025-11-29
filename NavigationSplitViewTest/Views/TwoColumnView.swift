//
//  TwoColumnView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI

struct TwoColumnView: View {

    @EnvironmentObject private var model: Model
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var editMode: EditMode = .inactive

    /// Set this to true if you want to select the first item on iPad
    private let autoSelectFirstItemOnPad = true

    /// Content
    @State private var selectedItems: Set<Item.ID> = []

    /// Search text
    @State private var searchText: String = ""

    /// Item list filtered by search text
    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return model.firstCategory.items
        } else {
            return model.firstCategory.items.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    enum DetailViewState {
        case selectedItem(Item)
        case none
        case editing
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedItems) {
                ForEach(filteredItems, id: \.id) { item in
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
                        .disabled(selectedItems.isEmpty)
                    }
                }
            }
            .onAppear {
                if selectedItems.isEmpty {
                    // On iPad it looks better if the first item is already selected
                    selectFirstItemOnIpad()
                }
            }
            .environment(\.editMode, $editMode) // Bind edit mode
            .onChange(of: editMode) { _, newMode in
                // Detect when edit mode finishes
                if newMode == .inactive {
                    // selectedItems is empty at this point
                    // On iPad it looks better if the first item is already selected
                    selectFirstItemOnIpad()
                }
            }
            .onChange(of: selectedItems) { oldValue, newValue in
                print("Selection \(oldValue) -> \(newValue)")
            }
            .onChange(of: searchText, { oldValue, newValue in
                selectFirstItemOnIpad()
            })
        } detail: {
            switch detailViewState {
            case .selectedItem(let item):
                DetailView(item: item)
            case .none:
                if searchText.isEmpty {
                    // You won't see this due to auto-selection of first item
                    Text("Please select a person")
                } else {
                    ContentUnavailableView.search
                }
            case .editing:
                Text("Editing")
                // alternative could be: EmptyView()
            }
        }
        .searchable(text: $searchText)
    }

    // MARK: - Detail view state

    private var detailViewState: DetailViewState {
        if editMode.isEditing {
            return .editing
        }
        else if let item = filteredItems.first(where: { $0.id == selectedItems.first }) {
            return .selectedItem(item)
        }

        return .none
    }

    // MARK: - Selection

    private func selectFirstItemOnIpad() {
        guard autoSelectFirstItemOnPad, UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }

        if let firstItem = filteredItems.first {
            print("Set selection to \(firstItem.id)")
            // TODO: this needs to be in a Task otherwise the selection will not be set, figure out why!
            Task {
                selectedItems = [firstItem.id]
            }
        }
    }

    // MARK: - Delete items

    // Used in swipe to delete
    private func deleteItems(at offsets: IndexSet) {
        // Remove items from selection
        for offset in offsets {
            if let item = model.firstCategory.items[safe: offset] {
                selectedItems.remove(item.id)
            }
        }

        // Remove from list
        model.deleteItemsInCategory(with: model.firstCategory.id, at: offsets)

        // Check if first item needs to be re-selected
        if editMode != .active && selectedItems.isEmpty {
            selectFirstItemOnIpad()
        }
    }

    // Used in delete selection button
    private func deleteSelection() {
        // Determine the indexes of selected items
        let offsets = IndexSet(model.firstCategory.items.enumerated().compactMap { index, item in
            selectedItems.contains(item.id) ? index : nil
        })

        // Perform the removal
        deleteItems(at: offsets)
    }
}

#Preview {
    TwoColumnView()
        .environmentObject(Model())
}
