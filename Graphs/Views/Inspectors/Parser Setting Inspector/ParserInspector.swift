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
    
    @Query(sort: \ParserSettings.name) var parserSettings: [ParserSettings]
    
    @State var selection: ParserSettings? = nil
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AvailableParserSettings
            
            Divider()
            
            if let selectedParser = selection {
                ParserEditor(parseSettings: selectedParser)
                    .padding(.horizontal)
            } else {
                ParseEditor_EmptySelection()
                    .padding(.horizontal)
            }
            
            Spacer()
            
        }
    }
    
    
    @ViewBuilder
    var AvailableParserSettings: some View {
        List(selection: $selection) {
            ForEach(parserSettings, id: \.self) { nextParser in
                Text(nextParser.name)
            }
        }
        .frame(height: 150)
        
        HStack {
            NewParserSettingButton
            DeleteParserSettingButton
                .disabled(selection == nil)
        }
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



#Preview {
    ParserInspector(selection: ParserSettings()).frame(height: 1000)
}
