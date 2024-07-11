//
//  ContentView.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/4/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var visibility_sourceList: NavigationSplitViewVisibility = .all
    @State private var visibility_inspector = true
    
    var body: some View {
        NavigationSplitView {
            Text("Source List")
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        } detail: {
            VSplitView {
                Text("Content List")
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                Text("Graphs")
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            }
            //.frame(minHeight: 100, maxHeight: .infinity)
        }
        .inspector(isPresented: $visibility_inspector) {
            Inspector()
                //.frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                .inspectorColumnWidth(min: 300, ideal: 350, max: 800)
                .toolbar() {
                    InspectorVisibilityButton
                }
        }
        .navigationSplitViewStyle(.automatic)
    }
    
    
    
    // MARK: - Buttons
    @ToolbarContentBuilder
    var InspectorVisibilityButton: some ToolbarContent {
        ToolbarItem(id: "inspector") {
            Button {
                visibility_inspector.toggle()
            } label: {
                Image(systemName: "sidebar.right")
            }
        }
    }
}

#Preview {
    ContentView()
}
