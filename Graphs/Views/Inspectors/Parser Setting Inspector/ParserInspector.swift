//
//  ParserInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/26/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData

struct ParserInspector: View {
    
    @Bindable var viewModel: ParserSettingsViewModel
    var lineNumberViewModel: LineNumberViewModel
    
    init(_ viewModel: ParserSettingsViewModel, lineNumberViewModel: LineNumberViewModel) {
        self.viewModel = viewModel
        self.lineNumberViewModel = lineNumberViewModel
    }
    
    //@State var selection: ParserSettings? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AvailableParserSettings
            
            Divider()
            
            if let selectedParser = viewModel.selection {
                ParserEditor(parseSettings: selectedParser)
                    .frame(maxHeight: 425)
                    //.padding(.horizontal, -20)
                    //.padding(.top, -20)
            } else {
                ParseEditor_EmptySelection()
                    .frame(maxHeight: 425)
                    //.padding(.horizontal, -20)
                    //.padding(.top, -20)
            }
            
            FileContentView
            
            Spacer()
            
        }
    }
    
    
    
    
    @ViewBuilder
    var AvailableParserSettings: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.parserSettings, id: \.self) { nextParser in
                Text(nextParser.name)
                    .contextMenu {
                        DeleteParserSettingButton
                        DupliateParserSettingsButton
                        ExportParserSettingsButton
                    }
            }
        }.listRowSeparator(.hidden)
        .frame(height: 150)
        .dropDestination(for: URL.self) { urls, _  in
            
            if viewModel.shouldAllowDrop(ofURLs: urls) == false {
                return false
            }
            
            let success = viewModel.importURLs(urls)
            return success
        }
        
        
        
        HStack {
            PlusParserSettingButton
            MinusParserSettingButton
                .disabled(viewModel.selection == nil)
        }
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    var FileContentView: some View {
        
        TextInspector(lineNumberViewModel)
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
        viewModel.newParserSettings()
    }
    
    private func deleteParser() {
        viewModel.deleteSelectedParserSetting()
    }
    
    
    private func duplateParser() {
        viewModel.duplicateParserSettings()
    }
    
    private func exportParser() {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.gparser ?? .data]
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            viewModel.exportParserSettings(to: url)
        }
    }
}



// MARK: - Preview
#Preview {
    
    let dataController = DataController(withDelegate: nil)
    let selectionManager = SelectionManager()
    let parserSettingsViewModel = ParserSettingsViewModel(dataController, selectionManager)
    let lineSettingsViewModel = LineNumberViewModel(nil)
    
    ParserInspector(parserSettingsViewModel, lineNumberViewModel: lineSettingsViewModel)
        .frame(height: 1000)
}
