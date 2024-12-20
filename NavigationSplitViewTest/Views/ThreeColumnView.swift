//
//  ThreeColumnView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI

struct ThreeColumnView: View {

    @EnvironmentObject private var model: Model
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var editMode: EditMode = .inactive
    
    /// Set this to true if you want to select the first item on iPad
    let autoSelectFirstItemOnPad = true

    // Sidebar
    @State private var selectedCategory: Category.ID?

    // Content
    @State private var selectedItems: Set<Item.ID> = []

    // Detail
    enum DetailViewState {
        case selectedItem(Item)
        case none
        case editing
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(model.categories, selection: Binding(
                get: { selectedCategory },
                set: { newValue in
                    // On compact size classes like iPhone the selection will
                    // always be reset to nil when this view becomes visible again.
                    // Work around this by prevent setting the value to 'nil'
                    if newValue != nil {
                        selectedCategory = newValue
                    }
                })) { category in
                    CategoryView(category: category)
                }
            .navigationTitle("Category")
            .onAppear {
                if selectedCategory == nil {
                    print("Category is nil, selecting first")
                    selectFirstCategory()

                    // On iPad it looks better if the first item is already selected
                    selectFirstItemOnIpad()
                }
            }
            .onChange(of: selectedCategory) { oldValue, newValue in
                let oldName = model.category(for: oldValue)?.name ?? "nil"
                let newName = model.category(for: newValue)?.name ?? "nil"
                print("Category \(oldName) -> \(newName)")

                // On iPad it looks better if the first item is already selected
                selectFirstItemOnIpad()
            }
        } content: {
            if let selectedCategory,
               let items = model.items(for: selectedCategory) {
                List(selection: $selectedItems) {
                    ForEach(items, id: \.id) { item in
                        ItemView(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle(model.title(for: selectedCategory))
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
                .environment(\.editMode, $editMode) // Bind edit mode
                .onChange(of: editMode) { _, newMode in
                    // Detect when edit mode changes
                    if newMode == .inactive {
                        // selectedItems is empty at this point
                        // On iPad it looks better if the first item is already selected
                        selectFirstItemOnIpad()
                    }
                }
                .onChange(of: selectedItems) { oldValue, newValue in
                    print("Selection \(oldValue) -> \(newValue)")
                }
            } else {
                Text("Please select a category")
            }
        } detail: {
            switch detailViewState {
            case .selectedItem(let item):
                DetailView(item: item)
            case .none:
                Text("Please select an item")
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
        else if let selectedCategory,
                let items = model.items(for: selectedCategory),
                let item = items.first(where: { $0.id == selectedItems.first }) {
            // In case of multiple selection this could lead to some interesting
            // behaviour because Set is unordered
            return .selectedItem(item)
        }

        return .none
    }

    // MARK: - Selection

    private func selectFirstCategory() {
        selectedCategory = model.categories.first?.id
    }

    private func selectFirstItemOnIpad() {
        guard autoSelectFirstItemOnPad, UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }

        if let selectedCategory,
           let items = model.items(for: selectedCategory),
           let firstItem = items.first {
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
        guard let selectedCategory,
              let items = model.items(for: selectedCategory) else {
            return
        }

        // Remove items from selection
        for offset in offsets {
            if let item = items[safe: offset] {
                selectedItems.remove(item.id)
            }
        }

        // Remove from list
        model.deleteItemsInCategory(with: selectedCategory, at: offsets)

        // Check if first item needs to be re-selected
        if editMode != .active && selectedItems.isEmpty {
            selectFirstItemOnIpad()
        }
    }

    // Used in delete selection button
    private func deleteSelection() {
        guard let selectedCategory,
              let items = model.items(for: selectedCategory) else {
            return
        }

        // Determine the indexes of selected items
        let offsets = IndexSet(items.enumerated().compactMap { index, item in
            selectedItems.contains(item.id) ? index : nil
        })

        // Perform the removal
        deleteItems(at: offsets)
    }}

#Preview {
    ThreeColumnView()
        .environmentObject(Model())
}
