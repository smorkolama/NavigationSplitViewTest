//
//  ItemView.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 15/12/2024.
//

import SwiftUI

struct ItemView: View {
    var item: Item

    var body: some View {
        VStack {
            Text(item.name)
        }
    }
}
