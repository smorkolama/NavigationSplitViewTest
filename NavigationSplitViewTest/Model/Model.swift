//
//  Model.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 15/12/2024.
//

import Foundation

struct Item: Identifiable, Equatable {
    var id = UUID()
    let name: String
    let description: String
}

class Model: ObservableObject {
    @Published var items: [Item] = [
        Item(name: "Football", description: "Really handy for playing football"),
        Item(name: "Badminton racket", description: "My trusty old racket"),
        Item(name: "Skateboard", description: "Gathering dust in the closet because I never use it"),
        Item(name: "Tennis racket", description: "If only I could play tennis this would be perfect"),
        Item(name: "Swimming goggles", description: "Protecting my eyes from the water"),
    ]
}
