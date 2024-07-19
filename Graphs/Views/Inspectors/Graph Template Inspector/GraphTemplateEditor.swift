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
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Name:")
                    .font(fontType)
                TextField("Name:", text: $graphTemplate.name)
                    .frame(minWidth: width, maxWidth: .infinity)
                Spacer()
            }
            
            GraphViewRepresentable(graphController: graphController)
            
        }
    }
}


// MARK: - Preview
/*
 #Preview {
     GraphTemplateEditor()
 }
 */

