//
//  Inspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct Inspector: View {
    var viewModel: InspectorViewModel
    
    init(_ viewModel: InspectorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabView {
            ParserInspector()
                //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                .tabItem { Text("􀋱") }
            GraphTemplateInspector()
                //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                .tabItem { Text("􀟪") }
            TextInspector(dataItem: viewModel.firstDataItem)
                //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                .tabItem { Text("􀈷") }
        }.frame(minWidth: 330, maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

#Preview {
    Inspector(InspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
