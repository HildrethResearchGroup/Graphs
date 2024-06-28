//
//  GraphTemplateEditor_EmptySelection.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct GraphTemplateEditor_EmptySelection: View {
    
    @State var name: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Name:")
                TextField("Name:", text: $name)
                    .frame(width: 200)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Spacer()
            }
        }
        
    }
}

#Preview {
    GraphTemplateEditor_EmptySelection()
}
