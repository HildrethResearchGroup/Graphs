//
//  DataItemsInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsInspector: View {
    
    @Bindable var viewModel: DataItemsInspectorViewModel
    
    
    init(_ viewModel: DataItemsInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Form {
            TextField("Name:", text: $viewModel.name)
                .onSubmit { viewModel.updateNames() }
                //.disabled(viewModel.disableNameTextfield)
            
            HStack {
                Text("FilePath:")
                Text(viewModel.filePath)
                Spacer()
                Button("􀉣") {
                    
                }
                .disabled(viewModel.disableNameFilepath)
            }
            
            VStack {
                HStack {
                    Text("Parser:")
                    Spacer()
                    Text(viewModel.parserSettingsName)
                }
                HStack {
                    Text("Set:")
                    Spacer()
                    parserSettingsView()
                        .disabled(viewModel.disableSettingsUpdate)
                }
            }
            
            VStack {
                HStack {
                    Text("Graph Template:")
                    Spacer()
                    Text(viewModel.graphTemplateName)
                }
                HStack {
                    Text("Set:")
                    Spacer()
                    graphTemplateView()
                        .disabled(viewModel.disableSettingsUpdate)
                }
            }
            
        }.formStyle(.grouped)
        
    }
    
    
    @ViewBuilder
    func parserSettingsView() -> some View {
        Menu("Parser:") {
            Button("None") {
                viewModel.updateParserSetting(with: .none, and: nil)
            }
            Button("Inherit") {
                viewModel.updateParserSetting(with: .defaultFromParent, and: nil)
            }
            
            ForEach(viewModel.availableParserSettings) { nextParserSetting in
                Button(nextParserSetting.name) {
                    viewModel.updateParserSetting(with: .directlySet, and: nextParserSetting)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func graphTemplateView() -> some View {
        Menu("Graph Template:") {
            Button("None") {
                viewModel.updateGraphtemplate(with: .none, and: nil)
            }
            Button("Inherit") {
                viewModel.updateGraphtemplate(with: .defaultFromParent, and: nil)
            }
            
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
    DataItemsInspector(DataItemsInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
