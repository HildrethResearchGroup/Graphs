//
//  ContentView.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/4/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            Text("Source List")
                //.frame(minHeight: 100, maxHeight: .infinity)
        } content: {
            VSplitView {
                Text("Content List")
                Text("Graphs")
            }
            //.frame(minHeight: 100, maxHeight: .infinity)
        } detail: {
            Text("Inspector")
                //.frame(minHeight: 100, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
