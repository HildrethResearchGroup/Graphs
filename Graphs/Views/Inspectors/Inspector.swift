//
//  Inspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct Inspector: View {
    var viewModel: InspectorViewModel
    
    init(_ viewModel: InspectorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabView {
            NodesInspectorView(viewModel.nodeInspectorVM)
                .tabItem { Text("􀈕") }
            DataItemsInspector(viewModel.dataItemsVM)
                .tabItem { Text("􀈿") }
            GraphTemplateInspector(viewModel.graphTemplateInspectorVM)
                //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                .tabItem { Text("􁂥") }
            ParserInspector(viewModel.parserSettingsVM)
                //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                .tabItem { Text("􀋱") }
        }
        .frame(minWidth: 330, maxWidth: .infinity, maxHeight: .infinity)
        
    }
}


// MARK: - Preview
#Preview {
    Inspector(InspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
