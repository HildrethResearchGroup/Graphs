//
//  ParserInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/26/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI
import SwiftData

struct ParserInspector: View {
    @Bindable var viewModel: InspectorViewModel

    init(_ viewModel: InspectorViewModel) {
        self.viewModel = viewModel
    }
    
    //@State var selection: ParserSettings? = nil
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            AvailableParserSettings
            
            Divider()
            
            if let selectedParser = viewModel.parserSettingsVM.selection {
                ParserEditor(parseSettings: selectedParser)
                    .frame(maxHeight: 475)
                    //.padding(.horizontal, -20)
                    //.padding(.vertical, -20)
            } else {
                ParseEditor_EmptySelection()
                    .frame(maxHeight: 475)
                    //.padding(.horizontal, -20)
                    //.padding(.vertical, -20)
            }
            FileContentView
                //.frame(minHeight: 400, maxHeight: .infinity)

            Spacer()
            
        }
    }
    
    
    
    
    @ViewBuilder
    var AvailableParserSettings: some View {
        List(selection: $viewModel.parserSettingsVM.selection) { // was \.self
            ForEach(viewModel.parserSettingsVM.parserSettings, id: \.self) { nextParser in
                Text(nextParser.name)
                    .foregroundStyle(viewModel.parserSettingsVM.foregroundColor(for: nextParser))
                    .contextMenu {
                        DeleteParserSettingButton
                        DupliateParserSettingsButton
                        ExportParserSettingsButton
                    }
            }
            .listRowSeparator(.hidden)
        }
        //.listRowSeparator(.hidden)
        .frame(height: 150)
        .dropDestination(for: URL.self) { urls, _  in
            if viewModel.parserSettingsVM.shouldAllowDrop(ofURLs: urls) == false { return false }
            
            let success = viewModel.parserSettingsVM.importURLs(urls)
            return success
        }
        
        
        
        HStack {
            PlusParserSettingButton
            MinusParserSettingButton
                .disabled(viewModel.parserSettingsVM.selection == nil)
        }
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    var FileContentView: some View {
        // ParseViewer
        if let dataItem = viewModel.parserSettingsVM.selectedDataItem {
            if dataItem.getAssociatedParserSettings()?.id == viewModel.parserSettingsVM.selection?.id {
                 VStack {
                     Divider()
                     ParseViewer(viewModel.tableInspectorVM, viewModel.textInspectorVM)
                 }
                 .background(.white)
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
        
    }
    
    
    
    // MARK: - Buttons
    @ViewBuilder
    private var PlusParserSettingButton: some View {
        Button(action: newParser, label: { Image(systemName: "plus") } )
            .buttonStyle(.borderless)
    }
    
    
    @ViewBuilder
    private var MinusParserSettingButton: some View {
        Button(action: deleteParser, label: { Image(systemName: "minus") } )
            .buttonStyle(.borderless)
    }
    
    
    @ViewBuilder
    private var DeleteParserSettingButton: some View {
        Button(action: deleteParser, label: { Text("Delete") } )
            .buttonStyle(.borderless)
    }
    
    
    @ViewBuilder
    private var DupliateParserSettingsButton: some View {
        Button(action: duplateParser) {
            Text("Duplicate")
        }
    }
    
    
    
    @ViewBuilder
    private var ExportParserSettingsButton: some View {
        Button(action: exportParser, label: { Text("Export") })
    }
    
    
    // MARK: - Functions
    private func newParser() {
        viewModel.parserSettingsVM.newParserSettings()
    }
    
    private func deleteParser() {
        viewModel.parserSettingsVM.deleteSelectedParserSetting()
    }
    
    
    private func duplateParser() {
        viewModel.parserSettingsVM.duplicateParserSettings()
    }
    
    private func exportParser() {
        let nc = NotificationCenter.default
        
        nc.post(name: .exportParserSettings, object: nil)
    }
}



// MARK: - Preview
#Preview {
    @Previewable
    @State var appController = AppController()
    ParserInspector(appController.inspectorVM)
        .frame(height: 1000)
}
