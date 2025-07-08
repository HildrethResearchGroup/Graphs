//
//  ParseEditor_EmptySelection.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ParseEditor_EmptySelection: View {
    @State var name: String = ""
    @State var number: Int = 0
    @State var toggleState = false
    @State var newLineType: NewLineType = .CRLF
    @State var stringEncoding: StringEncodingType = .ascii
    
    @State var separator: Separator = .comma
    
    //private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        Form() {
            TextField("Name:", text: $name)
            //.frame(minWidth: 100, maxWidth: .infinity)
                .disabled(true)
            VStack {
                Picker("New Line:", selection: $newLineType) {
                    ForEach(NewLineType.allCases) { nextLineType in
                        Text(nextLineType.name)
                    }
                }
                .help(NewLineType.toolTip)
                
                Picker("Encoding:", selection: $stringEncoding) {
                    ForEach(StringEncodingType.allCases) { nextEncoding in
                        Text(nextEncoding.rawValue)
                    }
                }
                .help(StringEncodingType.toolTip)
                
                
            }
            
            EditExperimentalDetails
            
            EditHeader
            
            EditData
        }
        .formStyle(.grouped)
        .disabled(true)
        .padding(.horizontal, -20)
        .padding(.top, -15)
    }
    
    @ViewBuilder
    var EditExperimentalDetails: some View {
        VStack(alignment: .leading) {
            Toggle("Experimental Details:", isOn: $toggleState)
                .font(.headline)
            TextField("Starting Line:", value: $number, format: .number)
            TextField("Ending Line:", value: $number, format: .number)
        }
    }
    
    
    @ViewBuilder
    var EditHeader: some View {
        
        VStack(alignment: .leading) {
            Toggle("Header:", isOn: $toggleState)
                .font(fontType)
            
            TextField("Starting Line:", value: $number, format: .number)

            TextField("Ending Line:", value: $number, format: .number)
            
            Picker("Separator:", selection: $separator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            }
            .help(Separator.toolTip)
            //.padding(.leading, 10)
        }
    }
    
    
    @ViewBuilder
    var EditData: some View {
        
        VStack(alignment: .leading) {
            Toggle("Data:", isOn: $toggleState)
                .font(fontType)
                .disabled(true)
            
            TextField("Starting Line:", value: $number, format: .number)
                .disabled(true)
            
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
        }
        
    }
    
}


// MARK: - Preview
#Preview {
    ParseEditor_EmptySelection()
}
