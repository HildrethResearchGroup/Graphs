//
//  GraphTemplateInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData


struct GraphTemplateInspector: View {
    
    @Query(sort: \GraphTemplate.name) var graphTempletes: [GraphTemplate]
    
    @State var selection: GraphTemplate? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            AvailableGraphTemplates
            
            Divider()
            
            if let selectedGraphTemplate = selection {
                GraphTemplateEditor(graphTemplate: selectedGraphTemplate)
            } else {
                GraphTemplateEditor_EmptySelection()
            }
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    var AvailableGraphTemplates: some View {
        List(selection: $selection) {
            ForEach(graphTempletes, id: \.self) { nextGraphTemplate in
                Text(nextGraphTemplate.name)
            }
        }
        .frame(height: 150)
        
        HStack {
            NewGraphTemplateButton
            DeleteGraphTemplateButton
                .disabled(selection == nil)
        }
    }
    
    // MARK: - Buttons
    @ViewBuilder
    var NewGraphTemplateButton: some View {
        Button(action: newGraph, label: { Image(systemName: "plus") } )
            .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var DeleteGraphTemplateButton: some View {
        Button(action: deleteGraph, label: { Image(systemName: "minus") } )
            .buttonStyle(.borderless)
    }
    
    
    // MARK: - Functions
    private func newGraph() {
        print("Implement new Graph")
    }
    
    private func deleteGraph() {
        print("Implement delete Graph")
    }
    
}

#Preview {
    GraphTemplateInspector()
}
