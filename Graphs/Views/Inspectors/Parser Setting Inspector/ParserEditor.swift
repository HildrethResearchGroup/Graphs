//
//  ParserEditor.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/26/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData

struct ParserEditor: View {
    
    @Bindable var parseSettings: ParserSettings
    
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    
    var body: some View {
        
        Form() {
            TextField("Name:", text: $parseSettings.name)
                //.frame(minWidth: 100, maxWidth: .infinity)
            
            VStack {
                Picker("New Line:", selection: $parseSettings.newLineType) {
                    ForEach(NewLineType.allCases) { nextLineType in
                        Text(nextLineType.name)
                    }
                }
                //.frame(minWidth: 150, maxWidth: 200)
                .help(NewLineType.toolTip)
                
                Picker("Encoding:", selection: $parseSettings.stringEncodingType) {
                    ForEach(StringEncodingType.allCases) { nextEncoding in
                        Text(nextEncoding.rawValue)
                    }
                }
                //.frame(minWidth: 150, maxWidth: 200)
                .help(StringEncodingType.toolTip)
                
            }
            
            EditExperimentalDetails
            
            EditHeader
            
            EditData

        }.formStyle(.grouped)
            .onAppear(
                
            )
        
    }
    
    @ViewBuilder
    var EditExperimentalDetails: some View {
        VStack {
            Toggle("Experimental Details:", isOn: $parseSettings.hasExperimentalDetails)
                .font(.headline)
            TextField("Starting Line:", value: $parseSettings.experimentalDetailsStart, format: .number)
                .disabled(!parseSettings.hasExperimentalDetails)
            TextField("Ending Line:", value: $parseSettings.experimentalDetailsEnd, format: .number)
                .disabled(!parseSettings.hasExperimentalDetails)
        }
    }
    
    @ViewBuilder
    var EditHeader: some View {
        VStack(alignment: .leading) {
            Toggle("Header:", isOn: $parseSettings.hasHeader)
                .font(fontType)
            
            TextField("Starting Line:", value: $parseSettings.headerStart, format: .number)
                //.frame(width: width)
                .disabled(!parseSettings.hasHeader)

            TextField("Ending Line:", value: $parseSettings.headerEnd, format: .number)
                //.frame(width: width)
                .disabled(!parseSettings.hasHeader)
            
            Picker("Separator:", selection: $parseSettings.headerSeparator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            }
            .help(Separator.toolTip)
            .disabled(!parseSettings.hasHeader)
            .padding(.leading, 10)
        }
        
    }
    
    @ViewBuilder
    var EditData: some View {
        
        VStack(alignment: .leading) {
            Toggle("Data:", isOn: $parseSettings.hasData)
                .font(fontType)
            TextField("Starting Line:", value: $parseSettings.dataStart, format: .number)
                .disabled(!parseSettings.hasData)
            
            // Data Separator
            Picker("Separator:", selection: $parseSettings.dataSeparator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            }
            //.frame(minWidth: 2*width + 25, alignment: .leading)
            .help(Separator.toolTip)
            .disabled(!parseSettings.hasData)
            .padding(.leading, 10)
            
            Toggle("Stop at Empty Line", isOn: $parseSettings.stopDataAtFirstEmptyLine)
                .padding(.leading, 10)
                .padding(.vertical, 10)
                .disabled(!parseSettings.hasData)
        }
        
    }

}


// MARK: - Preview
#Preview {
    ParserEditor(parseSettings: ParserSettings())
}


