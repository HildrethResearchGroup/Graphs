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
    
    @State var separator: Separator = .comma
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        VStack {
            HStack {
                Text("Name:").font(fontType)
                TextField("Name:", text: $name)
                    .frame(width: 200)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
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
                Toggle("", isOn: $toggleState).disabled(true)
                Text("Experimental Details")
                    .font(fontType)
                Spacer()
            }
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
            }.padding(.leading)
        }
    }
    
    
    @ViewBuilder
    var EditHeader: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Toggle("", isOn: $toggleState).disabled(true)
                Text("Header")
                    .font(fontType)
                Spacer()
            }
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
            }.padding(.leading)
            Picker(selection: $separator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            } label: {
                HStack {
                    Text("Separator").frame(width: width, alignment: .leading).padding(.leading)
                }
            }
            .frame(width: 2*width + 25, alignment: .leading)
                .disabled(true)
        }
    }
    
    
    @ViewBuilder
    var EditData: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .bottom) {
                Toggle("", isOn: $toggleState)
                    .disabled(true)
                Text("Data")
                    .font(fontType)
                Spacer()
            }
            
            HStack {
                Text("Starting Line")
                    .frame(width: width, alignment: .leading)
                TextField("Starting Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
                
            }.padding(.leading)
            
            HStack {
                Text("Ending Line")
                    .frame(width: width, alignment: .leading)
                TextField("Ending Line", value: $number, format: .number)
                    .frame(width: width)
                    .disabled(true)
                Spacer()
            }.padding(.leading)
            Picker(selection: $separator) {
                ForEach(Separator.allCases) { nextSeparator in
                    Text(nextSeparator.name)
                }
            } label: {
                HStack {
                    Text("Separator").frame(width: width, alignment: .leading).padding(.leading)
                }
            }.frame(width: 2*width + 25, alignment: .leading)
                .disabled(true)
        }
        
    }
    
}

#Preview {
    ParseEditor_EmptySelection()
}
