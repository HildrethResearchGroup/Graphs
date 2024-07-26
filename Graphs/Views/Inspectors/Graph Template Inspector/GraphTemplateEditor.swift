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
        
        Form() {
            TextField("Name:", text: $graphTemplate.name)
            GraphViewRepresentable(graphController: graphController)
        }.formStyle(.grouped)
    }
}


// MARK: - Preview
/*
 #Preview {
     GraphTemplateEditor()
 }
 */

