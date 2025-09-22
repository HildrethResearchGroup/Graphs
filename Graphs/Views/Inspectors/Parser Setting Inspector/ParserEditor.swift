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
    
    @AppStorage("expanded_parserSettings_editData") private var expanded_parserSettings_editData = true
    
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    
    var body: some View {
        
        Form {
            /*
             HNFormField("Name:") {
                 TextField("Name:", text: $parseSettings.name)
             }
             HNFormField("New Line:") {
                 Picker_newLineType($parseSettings.newLineType)}
             HNFormField("Encoding:") {
                 Picker_stringType($parseSettings.stringEncodingType) }
             */
            
            
            
             TextField("Name:", text: $parseSettings.name)
                 //.frame(minWidth: 100, maxWidth: .infinity)
             
             VStack {
                 Picker_newLineType($parseSettings.newLineType)
                 Picker_stringType($parseSettings.stringEncodingType)
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
            
            /*
             HNFormField("Starting Line:") {
                 TextField("Starting Line:", value: $parseSettings.experimentalDetailsStart, format: .number)
                     .disabled(!parseSettings.hasExperimentalDetails)
             }
             .padding(.leading, 10)
             */

             TextField("Ending Line:", value: $parseSettings.experimentalDetailsEnd, format: .number)
                 .disabled(!parseSettings.hasExperimentalDetails)
                 .padding(.leading, 10)
             
            
        } label: {
            Toggle("Experimental Details:", isOn: $parseSettings.hasExperimentalDetails)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    var EditHeader: some View {
        DisclosureGroup(isExpanded: $expanded_parserSettings_header) {
            /*
             HNFormField("Starting Line:") {
                 TextField("Starting Line:", value: $parseSettings.headerStart, format: .number)
                     //.frame(width: width)
                     .disabled(!parseSettings.hasHeader)
             }
             .padding(.leading, 10)
             */
            
            
             TextField("Starting Line:", value: $parseSettings.headerStart, format: .number)
                 //.frame(width: width)
                 .disabled(!parseSettings.hasHeader)
                 .padding(.leading, 10)
             
            /*
             HNFormField("Ending Line:") {
                 TextField("Ending Line:", value: $parseSettings.headerEnd, format: .number)
                     //.frame(width: width)
                     .disabled(!parseSettings.hasHeader)
             }
             .padding(.leading, 10)
             */
            
             TextField("Ending Line:", value: $parseSettings.headerEnd, format: .number)
                 //.frame(width: width)
                 .disabled(!parseSettings.hasHeader)
                 .padding(.leading, 10)
            
            /*
             HNFormField("Separator:") {
                 Picker("", selection: $parseSettings.headerSeparator) {
                     ForEach(Separator.allCases) { nextSeparator in
                         Text(nextSeparator.name)
                     }
                 }
                 .help(Separator.toolTip)
                 .disabled(!parseSettings.hasHeader)
             }
             .padding(.leading, 10)
             */
            
            
             Picker("Separator:", selection: $parseSettings.headerSeparator) {
                 ForEach(Separator.allCases) { nextSeparator in
                     Text(nextSeparator.name)
                 }
             }
             .help(Separator.toolTip)
             .disabled(!parseSettings.hasHeader)
             .padding(.leading, 10)
            
        } label: {
            Toggle("Header:", isOn: $parseSettings.hasHeader)
                .font(fontType)
        }
        
    }
    
    @ViewBuilder
    var EditData: some View {
        
        DisclosureGroup(isExpanded: $expanded_parserSettings_editData) {
            /*
             HNFormField("Starting Line:") {
                 TextField("Starting Line:", value: $parseSettings.dataStart, format: .number)
                     .disabled(!parseSettings.hasData)
                     .frame(alignment: .trailing)
             }
             .padding(.leading, 10)
             */
            

             TextField("Starting Line:", value: $parseSettings.dataStart, format: .number)
                 .disabled(!parseSettings.hasData)
                 .padding(.leading, 10)
            
            
            // Data Separator
            /*
             HNFormField("Separator:") {
                 Picker("", selection: $parseSettings.dataSeparator) {
                     ForEach(Separator.allCases) { nextSeparator in
                         Text(nextSeparator.name)
                     }
                 }
                 //.frame(minWidth: 2*width + 25, alignment: .leading)
                 .help(Separator.toolTip)
                 .disabled(!parseSettings.hasData)
             }
             .padding(.leading, 10)
             */
            
             Picker("Separator:", selection: $parseSettings.dataSeparator) {
                 ForEach(Separator.allCases) { nextSeparator in
                     Text(nextSeparator.name)
                 }
             }
             .help(Separator.toolTip)
             .disabled(!parseSettings.hasData)
             .padding(.leading, 10)
            
            
            /*
             HNFormField("") {
                 Toggle("Stop at Empty Line", isOn: $parseSettings.stopDataAtFirstEmptyLine)
                     //.padding(.leading, 10)
                     .disabled(!parseSettings.hasData)
             }
             .padding(.leading, 10)
             */
            

             Toggle("Stop at Empty Line", isOn: $parseSettings.stopDataAtFirstEmptyLine)
                 //.padding(.leading, 10)
                 .padding(.leading, 10)
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


