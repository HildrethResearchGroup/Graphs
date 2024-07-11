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
    
    //@AppStorage("parserInspector_experimentalDetailsDisclosed") var experimentalDetailsDisclosed = false
    //@AppStorage("parserInspector_headerDisclosed") var headerDisclosed = false
    //@AppStorage("parserInspector_dataDisclosed") var dataDisclosed = false
    
    
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Name:").font(fontType)
                TextField("Name:", text: $parseSettings.name)
                    .frame(minWidth: 100, maxWidth: .infinity)
                Spacer()
            }
            HStack {
                Picker("New Line", selection: $parseSettings.newLineType) {
                    ForEach(NewLineType.allCases) { nextLineType in
                        Text(nextLineType.name)
                    }

                }
                .frame(width: 120)
                
                Picker("Encoding", selection: $parseSettings.stringEncodingType) {
                    ForEach(StringEncodingType.allCases) { nextEncoding in
                        Text(nextEncoding.rawValue)
                    }
                }
                .frame(minWidth: 150, maxWidth: 200)
                
                Spacer()
            }
            
            EditExperimentalDetails
            
            EditHeader
            
            EditData

        }
        
    }
    
    @ViewBuilder
    var EditExperimentalDetails: some View {
        VStack {
            HStack(alignment: .bottom) {
                Toggle("", isOn: $parseSettings.hasExperimentalDetails)
                Text("Experimental Details")
                    .font(fontType)
                Spacer()
            }
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $parseSettings.experimentalDetailsStart, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasExperimentalDetails)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $parseSettings.experimentalDetailsEnd, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasExperimentalDetails)
                Spacer()
            }.padding(.leading)
        }
    }
    
    @ViewBuilder
    var EditHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Toggle("", isOn: $parseSettings.hasHeader)
                Text("Header")
                    .font(fontType)
                Spacer()
            }
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $parseSettings.headerStart, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasHeader)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $parseSettings.headerEnd, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasHeader)
                Spacer()
            }.padding(.leading)
            Picker(selection: $parseSettings.headerSepatator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            } label: {
                HStack {
                    Text("Separator").frame(width: width, alignment: .leading).padding(.leading)
                }
            }
            .frame(width: 2*width + 25, alignment: .leading)
                .disabled(!parseSettings.hasHeader)
        }
        
    }
    
    @ViewBuilder
    var EditData: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .bottom) {
                Toggle("", isOn: $parseSettings.hasData)
                Text("Data")
                    .font(fontType)
                Spacer()
            }
            
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $parseSettings.dataStart, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasData)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $parseSettings.dataEnd, format: .number)
                    .frame(width: width)
                    .disabled(!parseSettings.hasData)
                Spacer()
            }.padding(.leading)
            Picker(selection: $parseSettings.dataSeparator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            } label: {
                HStack {
                    Text("Separator").frame(width: width, alignment: .leading).padding(.leading)
                }
            }.frame(width: 2*width + 25, alignment: .leading)
                .disabled(!parseSettings.hasData)
        }
        
    }

}

#Preview {
    ParserEditor(parseSettings: ParserSettings())
}


