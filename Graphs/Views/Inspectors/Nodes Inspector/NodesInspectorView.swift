//
//  NodesInspectorView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/19/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
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
            OpenInFinderView
            VStack {
                HStack {
                    Text("Parser:")
                    Spacer()
                    ParserSettingsView()
                        .disabled(viewModel.disableSettingsUpdate)
                }
            }
            VStack {
                HStack {
                    Text("Graph Template:")
                    Spacer()
                    GraphTemplateView()
                        .disabled(viewModel.disableSettingsUpdate)
                }
            }
            
        }.formStyle(.grouped)
    }
    
    
    @ViewBuilder
    private var OpenInFinderView: some View {
        if viewModel.nodes.count == 1 {
            if let url = viewModel.nodes.first?.originalURL {
                HStack {
                    Text("Filepath:")
                    Text(url.path(percentEncoded: false))
                    Button("􀉣") { url.showInFinder() }
                }
            }
            else {
                EmptyView()
            }
            
        } else {
            EmptyView()
        }
        
        
    }
    
    @ViewBuilder
    private func ParserSettingsView() -> some View {
        Menu(viewModel.parserSettingsMenuText) {
            
            Button("None") {
                viewModel.updateParserSetting(with: .none, and: nil)
            }
            Button("Inherit") {
                viewModel.updateParserSetting(with: .defaultFromParent, and: nil)
            }.disabled(viewModel.inheretButtonDisabled)
            Divider()
            ForEach(viewModel.availableParserSettings) { nextParserSetting in
                Button(nextParserSetting.name) {
                    viewModel.updateParserSetting(with: .directlySet, and: nextParserSetting)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func GraphTemplateView() -> some View {
        Menu(viewModel.graphMenuText) {
            Button("None") {
                viewModel.updateGraphtemplate(with: .none, and: nil)
            }
            Button("Inherit") {
                viewModel.updateGraphtemplate(with: .defaultFromParent, and: nil)
            }.disabled(viewModel.inheretButtonDisabled)
            
            Divider()
            
            ForEach(viewModel.availableGraphTemplates) { nextGraphTemplate in
                Button(nextGraphTemplate.name) {
                    viewModel.updateGraphtemplate(with: .directlySet, and: nextGraphTemplate)
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    NodesInspectorView(NodeInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
