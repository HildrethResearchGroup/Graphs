//
//  NodesInspectorView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/19/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

@MainActor
struct NodesInspectorView: View {
    
    @Bindable var viewModel: NodeInspectorViewModel
    
    init(_ viewModel: NodeInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Form {
            TextField("Name:", text: $viewModel.name)
                .onSubmit { viewModel.updateNames() }
                .disabled(viewModel.disableNameTextfield)
            HStack {
                Text("Path:")
                Spacer()
                Text(viewModel.folderPath)
            }
            //OpenInFinderView
            ParserSettingsView()
            GraphTemplateView()
            
        }.formStyle(.grouped)
    }
    
    
    @ViewBuilder
    private var OpenInFinderView: some View {
        if viewModel.nodes.count == 1 {
            if let url = viewModel.nodes.first?.originalURL {
                HStack {
                    Text("Filepath:")
                    Text(url.path(percentEncoded: false))
                        .truncationMode(.head)
                        .lineLimit(2)
                        .help(url.path(percentEncoded: false))
                    Button("􀉣") { url.showInFinder() }
                }
            }
            else { EmptyView() }
        } else { EmptyView() }
    }
    
    
    @ViewBuilder
    private func ParserSettingsView() -> some View {
        
        HStack {
            Text("Parser:")
            Spacer()
            
            Menu(viewModel.parserSettingsMenuText) {
                
                Button("None") {
                    viewModel.updateParserSetting(with: .none, and: nil)
                }
                Button(viewModel.inheritParserSettingsName) {
                    viewModel.updateParserSetting(with: .defaultFromParent, and: nil)
                }.disabled(viewModel.inheritButtonDisabled)
                Divider()
                ForEach(viewModel.availableParserSettings) { nextParserSetting in
                    Button(nextParserSetting.name) {
                        viewModel.updateParserSetting(with: .directlySet, and: nextParserSetting)
                    }
                }
            }.disabled(viewModel.disableSettingsUpdate)
        }
    }
    
    
    @ViewBuilder
    func GraphTemplateView() -> some View {
        
        HStack {
            Text("Graph Template:")
            Spacer()
            
            
            Menu(viewModel.graphMenuText) {
                Button("None") {
                    viewModel.updateGraphtemplate(with: .none, and: nil)
                }
                Button(viewModel.inheritGraphTemplateName) {
                    viewModel.updateGraphtemplate(with: .defaultFromParent, and: nil)
                }.disabled(viewModel.inheritButtonDisabled)
                
                Divider()
                
                ForEach(viewModel.availableGraphTemplates) { nextGraphTemplate in
                    Button(nextGraphTemplate.name) {
                        viewModel.updateGraphtemplate(with: .directlySet, and: nextGraphTemplate)
                    }
                }
            }
            .frame(alignment: .trailing)
            .disabled(viewModel.disableSettingsUpdate)
            
        }
        
        
    }
}


// MARK: - Preview
#Preview {
    NodesInspectorView(NodeInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
