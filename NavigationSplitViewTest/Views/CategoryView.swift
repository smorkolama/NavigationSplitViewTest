//
//  CategoryView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 20/12/2024.
//

import SwiftUI

struct CategoryView: View {
    let category: Category

    var body: some View {
        Text(category.name)
            .font(.title3)
            .bold()
    }
}

#Preview {
    CategoryView(category: Model().categories.first!)
}
