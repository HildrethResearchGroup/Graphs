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
    
    @AppStorage("openLotsOfFinderItems") private var openLotsOfFinderItems = true
    @State private var shouldDisplayFinderWarning = false
    
    
    init(_ viewModel: DataItemsInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Form {
            TextField("Name:", text: $viewModel.name)
                .onSubmit { viewModel.updateNames() }
                .disabled(viewModel.disableNameTextfield)
            
            openFilesView()
            
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
        Menu(viewModel.parserSettingsMenuText) {
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
        Menu(viewModel.graphMenuText) {
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
    
    
    
    @ViewBuilder
    func openFilesView() -> some View {
        HStack {
            Text("FilePath:")
            Text(viewModel.filePath)
            Spacer()
            Button("􀉣") { openDataItemsInFinder()}
            .disabled(viewModel.disableNameFilepath)
            .alert("This will open \(viewModel.dataItemsCount) Finder Windows.  Are you sure you want to do this?", isPresented: $shouldDisplayFinderWarning) {
                Button("Yes", role: .cancel) {viewModel.openInFinder()}
                Button("No", role: .destructive) {}
            }
        }
    }
    
    func openDataItemsInFinder() {
        let count = viewModel.dataItemsCount
        
        if openLotsOfFinderItems == true {
            viewModel.openInFinder()
        } else {
            if count <= 10 {
                viewModel.openInFinder()
            } else {
                self.shouldDisplayFinderWarning = true
            }
        }
    }
}


// MARK: - Preview
#Preview {
    DataItemsInspector(DataItemsInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
