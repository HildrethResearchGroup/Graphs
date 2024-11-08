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
    
    @Bindable var viewModel: GraphTemplateInspectorViewModel
    
    init(_ viewModel: GraphTemplateInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            AvailableGraphTemplates
            
            Divider()
            
            if let selectedGraphTemplate = viewModel.selection {
                GraphTemplateEditor(graphTemplate: selectedGraphTemplate)
            } else {
                GraphTemplateEditor_EmptySelection()
            }
        }
    }
    
    
    @ViewBuilder
    var AvailableGraphTemplates: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.graphTemplates, id: \.self) { nextGraphTemplate in
                Text(nextGraphTemplate.name)
                    .contextMenu {
                        Button("Delete") {
                            deleteGraphTemplate(nextGraphTemplate)
                        }
                        Button("Show in Finder") {
                            showInFinder(nextGraphTemplate)
                        }
                    }
            }
        }
        .frame(height: 150)
        
        HStack {
            NewGraphTemplateButton
            DeleteGraphTemplateButton
                .disabled(viewModel.selection == nil)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Buttons
    @ViewBuilder
    var NewGraphTemplateButton: some View {
        Button(action: importGraph, label: { Image(systemName: "plus") } )
            .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var DeleteGraphTemplateButton: some View {
        Button(action: deleteSelectedGraph, label: { Image(systemName: "minus") } )
            .buttonStyle(.borderless)
    }
    
    
    // MARK: - Functions
    private func importGraph() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.dgraph ?? .data]
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            viewModel.importURLs(urls)
        }
    }
    
    private func deleteSelectedGraph() {
        viewModel.deleteSelectedGraphTemplate()
    }
    
    
    private func deleteGraphTemplate(_ graphTemplate: GraphTemplate) {
        viewModel.delete(graphTemplate: graphTemplate)
    }
    
    private func showInFinder(_ graphTemplate: GraphTemplate) {
        graphTemplate.url.showInFinder()
    }
    
}


// MARK: - Preview
#Preview {
    GraphTemplateInspector(GraphTemplateInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
