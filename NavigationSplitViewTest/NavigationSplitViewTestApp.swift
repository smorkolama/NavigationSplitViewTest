//
//  NavigationSplitViewTestApp.swift
//  NavigationSplitViewTest
//
//  Created by Benjamin van den Hout on 13/12/2024.
//

import SwiftUI

@main
struct NavigationSplitViewTestApp: App {
    enum ColumnView {
        case none
        case twoColumn
        case threeColumn
    }

    @StateObject private var model = Model()
    @State private var selectedColumn: ColumnView = .none

    var body: some Scene {
        WindowGroup {
            switch selectedColumn {
            case .none:
                VStack {
                    Text("Select desired column view")
                        .font(.title)
                        .padding()

                    Group {
                        Button("Two columns") {
                            selectedColumn = .twoColumn
                        }
                        Button("Three columns") {
                            selectedColumn = .threeColumn
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            case .twoColumn:
                TwoColumnView()
                    .environmentObject(model)
            case .threeColumn:
                ThreeColumnView()
                    .environmentObject(model)

            }
        }
    }
}
