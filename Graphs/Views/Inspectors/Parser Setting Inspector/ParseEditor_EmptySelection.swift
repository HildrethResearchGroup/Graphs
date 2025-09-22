//
//  ParseEditor_EmptySelection.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/27/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct ParseEditor_EmptySelection: View {
    @State var name: String = ""
    @State var number: Int = 0
    @State var toggleState = false
    @State var newLineType: NewLineType = .CRLF
    @State var stringEncoding: StringEncodingType = .ascii
    
    @State var separator: Separator = .comma
    
    
    @AppStorage("expanded_parserSettings_experimentalDetails") private var expanded_parserSettings_experimentalDetails = true
    
    @AppStorage("expanded_parserSettings_header") private var expanded_parserSettings_header = true
    
    @AppStorage("expanded_parserSettings_header") private var expanded_parserSettings_editData = true
    
    //private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        Form() {
            TextField("Name:", text: $name)
            //.frame(minWidth: 100, maxWidth: .infinity)
                .disabled(true)
            VStack {
                Picker_newLineType($newLineType)
                    .disabled(true)
                Picker_stringType($stringEncoding)
                    .disabled(true)
            }
            
            EditExperimentalDetails
            
            EditHeader
            
            EditData
        }
        .formStyle(.grouped)
        //.disabled(true)
        .padding(.horizontal, -20)
        //.padding(.vertical, -20)
        .scrollContentBackground(.hidden)
        .background(.clear)
        
    }
    
    @ViewBuilder
    var EditExperimentalDetails: some View {
        DisclosureGroup(isExpanded: $expanded_parserSettings_experimentalDetails) {
            TextField("Starting Line:", value: $number, format: .number)
                .padding(.leading, 10)
            TextField("Ending Line:", value: $number, format: .number)
                .padding(.leading, 10)
        } label: {
            Toggle("Experimental Details:", isOn: $toggleState)
                .font(.headline)
                .disabled(true)
        }
    }
    
    
    @ViewBuilder
    var EditHeader: some View {
        
        DisclosureGroup(isExpanded: $expanded_parserSettings_header) {
            TextField("Starting Line:", value: $number, format: .number)
                .padding(.leading, 10)

            TextField("Ending Line:", value: $number, format: .number)
                .padding(.leading, 10)
            
            Picker("Separator:", selection: $separator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            }
            .help(Separator.toolTip)
            .padding(.leading, 10)
        } label: {
            Toggle("Header:", isOn: $toggleState)
                .font(fontType)
                .disabled(true)
        }
    }
    
    
    @ViewBuilder
    var EditData: some View {
        
        DisclosureGroup(isExpanded: $expanded_parserSettings_editData) {
            TextField("Starting Line:", value: $number, format: .number)
                .disabled(true)
                .padding(.leading, 10)
            
            // Data Separator
            Picker("Separator:", selection: $separator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            }
            //.frame(minWidth: 2*width + 25, alignment: .leading)
            .help(Separator.toolTip)
            .disabled(true)
            .padding(.leading, 10)
            
            Toggle("Stop at Empty Line", isOn: $toggleState)
                .padding(.leading, 10)
                .padding(.vertical, 10)
                .disabled(true)
        } label: {
            Toggle("Data:", isOn: $toggleState)
                .font(fontType)
                .disabled(true)
        }
        
    }
    
}


// MARK: - Preview
#Preview {
    ParseEditor_EmptySelection()
}
