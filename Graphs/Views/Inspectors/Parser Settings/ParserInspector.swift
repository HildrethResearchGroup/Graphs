//
//  ParserInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/26/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ParserInspector: View {
    
    var parsers: [ParserSettings]
    
    @State var selection: ParserSettings? = nil
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            List(parsers, selection: $selection) { nextParser in
                Text(nextParser.name)
            }.frame(height: 150)
            
            HStack {
                
                Button(action: newParser, label: { Image(systemName: "plus") } )
                Button(action: deleteParser, label: { Image(systemName: "minus") } ).padding(-8)
            }
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
    
    func newParser() {
        print("Implment new Parser")
    }
    
    func deleteParser() {
        print("Implement delete Parser")
    }
}



#Preview {
    ParserInspector(parsers: [.init()], selection: ParserSettings()).frame(height: 1000)
}
