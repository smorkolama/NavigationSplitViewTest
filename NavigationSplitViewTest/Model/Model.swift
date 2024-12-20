//
//  Model.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 15/12/2024.
//

import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let name: String
    var items: [Item]
}

struct Item: Identifiable, Equatable, Hashable {
    var id = UUID()
    let name: String
    let description: String
}

class Model: ObservableObject {
    init() {
        print("INIT MODEL")
    }

    @Published var categories: [Category] = [
        Category(name: "Sports", items: [
            Item(name: "Football", description: "Really handy for playing football"),
            Item(name: "Badminton racket", description: "My trusty old racket"),
            Item(name: "Skateboard", description: "Gathering dust in the closet because I never use it"),
            Item(name: "Tennis racket", description: "If only I could play tennis this would be perfect"),
            Item(name: "Swimming goggles", description: "Protecting my eyes from the water"),
        ]),
        Category(name: "Services", items: [
            Item(name: "Electricity", description: "Needed for everything"),
            Item(name: "Water", description: "Needed for drinking"),
            Item(name: "Gas", description: "Needed for cooking"),
            Item(name: "Food", description: "Needed for eating"),
            Item(name: "Cleaning", description: "Needed for keeping things clean"),
        ]),
        Category(name: "Animals", items: [
            Item(name: "Guinea pig", description: "Really cute"),
            Item(name: "Cat", description: "Meow"),
            Item(name: "Dog", description: "Bark"),
            Item(name: "Bird", description: "Tweet"),
            Item(name: "Fish", description: "Swim"),
        ])
    ]

    // MARK: - Category

    func category(for id: Category.ID?) -> Category? {
        categories.first(where: { $0.id == id })
    }

    func title(for id: Category.ID) -> String {
        guard let category = categories.first(where: { $0.id == id }) else {
            return "All items"
        }

        return category.name
    }

    var firstCategory: Category {
        categories.first!
    }

    // MARK: - Item

    func items(for id: Category.ID) -> [Item]? {
        guard let category = categories.first(where: { $0.id == id }) else {
            return nil
        }

        return category.items
    }

    func deleteItemsInCategory(with id: Category.ID, at offsets: IndexSet) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == id }) else {
            return
        }

        categories[categoryIndex].items.remove(atOffsets: offsets)
    }
}
