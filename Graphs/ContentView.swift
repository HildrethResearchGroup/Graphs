//
//  ContentView.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/4/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var appController: AppController
    
    @State private var visibility_sourceList: NavigationSplitViewVisibility = .all
    @State private var visibility_inspector = true
    
    
    
    
    init(_ appController: AppController) {
        self.appController = appController
    }
    
    
    var body: some View {
        NavigationSplitView {
            SourceList(appController.sourceListVM)
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        } detail: {
            CenterContent(appController.dataListVM, appController.graphListVM)
            //.frame(minHeight: 100, maxHeight: .infinity)
        }
        .inspector(isPresented: $visibility_inspector) {
            Inspector(appController.inspectorVM)
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
                    .help(visibility_inspector ? "Hide Inspectors" : "Show Inspectors")
            }
        }
    }
}

#Preview {
    ContentView(AppController())
}


