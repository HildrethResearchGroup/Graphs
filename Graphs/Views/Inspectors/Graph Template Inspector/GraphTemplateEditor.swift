//
//  GraphTemplateEditor.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData

struct GraphTemplateEditor: View {
    
    @Bindable var graphTemplate: GraphTemplate
    
    @State var graphController = GraphController()
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Name:")
                TextField("Name:", text: $graphTemplate.name)
                    .frame(width: 200)
                Spacer()
            }
            
            GraphViewRepresentable(graphController: graphController)
            
        }
        
        
        
        
    }
    
}
