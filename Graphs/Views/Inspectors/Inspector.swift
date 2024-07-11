//
//  Inspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct Inspector: View {
    var dataItem: DataItem?
    
    var body: some View {
        TabView {
            ParserInspector()
                .tabItem { Text("􀋱") }
            GraphTemplateInspector()
                .tabItem { Text("􀟪") }
            TextInspector(dataItem: dataItem)
                .tabItem { Text("􀈷") }
        }
    }
}

#Preview {
    Inspector(dataItem: DataItem(url: Bundle.main.url(forResource: "diluteHF - 3 - Volts", withExtension: "dat") ?? URL(fileURLWithPath: ""), node: Node(url: nil, parent: nil)))
}
