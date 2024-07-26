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
    
    init(_ viewModel: ParserSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    //@State var selection: ParserSettings? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AvailableParserSettings
            
            Divider()
            ScrollView(.vertical) {
                if let selectedParser = viewModel.selection {
                    ParserEditor(parseSettings: selectedParser)
                } else {
                    ParseEditor_EmptySelection()
                }
            }
            
        }
    }
    
    
    @ViewBuilder
    var AvailableParserSettings: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.parserSettings, id: \.self) { nextParser in
                Text(nextParser.name)
            }
        }
        .frame(height: 150)
        
        HStack {
            NewParserSettingButton
            DeleteParserSettingButton
                .disabled(viewModel.selection == nil)
        }
        .padding(.horizontal)
    }
    
    
    // MARK: - Buttons
    @ViewBuilder
    var NewParserSettingButton: some View {
        Button(action: newParser, label: { Image(systemName: "plus") } )
            .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var DeleteParserSettingButton: some View {
        Button(action: deleteParser, label: { Image(systemName: "minus") } )
            .buttonStyle(.borderless)
    }
    
    
    // MARK: - Functions
    private func newParser() {
        print("Implment new Parser")
    }
    
    private func deleteParser() {
        print("Implement delete Parser")
    }
}



// MARK: - Preview
#Preview {
    ParserInspector(ParserSettingsViewModel(DataController(withDelegate: nil), SelectionManager())).frame(height: 1000)
}
