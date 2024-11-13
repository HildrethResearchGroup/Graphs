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
    
    private var graphController: GraphController {
        let url = graphTemplate.url
        
        let dgController = DGController(contentsOfFile: url.path(percentEncoded: false))
        
        let graphController = GraphController(dgController: dgController, data: nil)
        
        return graphController
    }
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        VStack {
            Form() {
                TextField("Name:", text: $graphTemplate.name)
                OpenFilesView
                
                
            }.formStyle(.grouped)
            GraphViewRepresentable(graphController: graphController)
        }
    }
    
    
    private var OpenFilesView: some View {
        HStack {
            Text("Filepath:")
            Text(graphTemplate.url.path(percentEncoded: false))
                .truncationMode(.head)
                .lineLimit(2)
                .help(graphTemplate.url.path(percentEncoded: false))
            Spacer()
            Button("􀉣") { graphTemplate.url.showInFinder()}
        }
    }
    
    
}


// MARK: - Preview
/*
 #Preview {
     GraphTemplateEditor()
 }
 */

