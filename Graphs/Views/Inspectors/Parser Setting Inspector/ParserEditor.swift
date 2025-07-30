//
//  ParserEditor.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/26/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI
import SwiftData

struct ParserEditor: View {
    
    @Bindable var parseSettings: ParserSettings
    
    @AppStorage("expanded_parserSettings_experimentalDetails") private var expanded_parserSettings_experimentalDetails = true
    
    @AppStorage("expanded_parserSettings_header") private var expanded_parserSettings_header = true
    
    @AppStorage("expanded_parserSettings_header") private var expanded_parserSettings_editData = true
    
    
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
                    ForEach(StringEncodingType.primaryEncodings) { nextEncoding in
                        Text(nextEncoding.rawValue)
                    }
                    Divider()
                    ForEach(StringEncodingType.secondaryEncodings) { nextEncoding in
                        Text(nextEncoding.rawValue)
                    }
                }
                //.frame(minWidth: 150, maxWidth: 200)
                .help(StringEncodingType.toolTip)
                
            }
            
            EditExperimentalDetails
            
            EditHeader
            
            EditData

        }
        .formStyle(.grouped)
        .padding(.horizontal, -20)
    }
    
    @ViewBuilder
    var EditExperimentalDetails: some View {
        DisclosureGroup(isExpanded: $expanded_parserSettings_experimentalDetails) {
            TextField("Starting Line:", value: $parseSettings.experimentalDetailsStart, format: .number)
                .disabled(!parseSettings.hasExperimentalDetails)
            TextField("Ending Line:", value: $parseSettings.experimentalDetailsEnd, format: .number)
                .disabled(!parseSettings.hasExperimentalDetails)
        } label: {
            Toggle("Experimental Details:", isOn: $parseSettings.hasExperimentalDetails)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    var EditHeader: some View {
        DisclosureGroup(isExpanded: $expanded_parserSettings_header) {
            /*
             Toggle("Header:", isOn: $parseSettings.hasHeader)
                 .font(fontType)
             */
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
            //.padding(.leading, 10)
        } label: {
            Toggle("Header:", isOn: $parseSettings.hasExperimentalDetails)
                .font(fontType)
        }
        
    }
    
    @ViewBuilder
    var EditData: some View {
        
        DisclosureGroup(isExpanded: $expanded_parserSettings_editData) {
            /*
             Toggle("Data:", isOn: $parseSettings.hasData)
                 .font(fontType)
             */
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
            //.padding(.leading, 10)
            
            Toggle("Stop at Empty Line", isOn: $parseSettings.stopDataAtFirstEmptyLine)
                //.padding(.leading, 10)
                .padding(.vertical, 10)
                .disabled(!parseSettings.hasData)
        } label: {
            Toggle("Data:", isOn: $parseSettings.hasData)
                .font(fontType)
        }
        
    }

}


// MARK: - Preview
#Preview {
    ParserEditor(parseSettings: ParserSettings())
}


