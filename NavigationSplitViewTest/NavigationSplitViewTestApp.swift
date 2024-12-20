//
//  NavigationSplitViewTestApp.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI

@main
struct NavigationSplitViewTestApp: App {
    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
//            TwoColumnView()
            ThreeColumnView()
                .environmentObject(model)
        }
    }
}
