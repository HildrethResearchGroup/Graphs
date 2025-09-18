//
//  DataItemsInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
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
            HStack {
                Text("Folder:")
                Spacer()
                Text(viewModel.folderName)
            }
            .help(viewModel.folderPath)
            OpenFilesView()
            ParserSettingsView()
            GraphTemplateView()
        }
        .formStyle(.grouped)
        .padding(.horizontal, -20)
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
                }
                Divider()
                ForEach(viewModel.availableParserSettings) { nextParserSetting in
                    Button(nextParserSetting.name) {
                        viewModel.updateParserSetting(with: .directlySet, and: nextParserSetting)
                    }
                }
            }
            .disabled(viewModel.disableSettingsUpdate)
            .help(viewModel.toolTip_ParserSettings)
        }
    }
    
    
    @ViewBuilder
    private func GraphTemplateView() -> some View {
        HStack {
            Text("Graph:")
            Spacer()
            
            Menu(viewModel.graphMenuText) {
                Button("None") {
                    viewModel.updateGraphtemplate(with: .none, and: nil)
                }
                Button(viewModel.inheritGraphTemplateName) {
                    viewModel.updateGraphtemplate(with: .defaultFromParent, and: nil)
                }
                Divider()
                ForEach(viewModel.availableGraphTemplates) { nextGraphTemplate in
                    Button(nextGraphTemplate.name) {
                        viewModel.updateGraphtemplate(with: .directlySet, and: nextGraphTemplate)
                    }
                }
            }
            .disabled(viewModel.disableSettingsUpdate)
            .help(viewModel.toolTip_GraphTemplate)
        }
    }
    
    
    
    @ViewBuilder
    private func OpenFilesView() -> some View {
        HStack {
            Text("FilePath:")
            Text(viewModel.truncatedFilePath)
                .truncationMode(.head)
                .lineLimit(2)
                .help(viewModel.filePath)
            Spacer()
            Button("􀉣") { openDataItemsInFinder()}
            .disabled(viewModel.disableNameFilepath)
            .help(viewModel.toolTip_openFiles)
            .alert("This will open \(viewModel.dataItemsCount) Finder Windows.  Are you sure you want to do this?", isPresented: $shouldDisplayFinderWarning) {
                Button("Yes", role: .cancel) {viewModel.openInFinder()}
                Button("No", role: .destructive) {}
            }
        }
    }
    
    
    private func openDataItemsInFinder() {
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
