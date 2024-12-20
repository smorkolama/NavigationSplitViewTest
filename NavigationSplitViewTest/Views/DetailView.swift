//
//  DetailView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 15/12/2024.
//

import SwiftUI

struct DetailView: View {
    var item: Item

    var body: some View {
        VStack {
            Text(item.name)
                .font(.headline)
                .padding(.vertical)
            Text(item.description)
        }
        .navigationTitle("Details for \(item.name)")
    }
}

#Preview {
    DetailView(item: Model().categories.first!.items.first!)
}
