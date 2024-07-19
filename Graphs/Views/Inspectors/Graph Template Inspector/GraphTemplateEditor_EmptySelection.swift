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
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        VStack {
            HStack {
                Text("Name:")
                    .font(fontType)
                TextField("Name:", text: $name)
                    .frame(minWidth: width, maxWidth: .infinity)
                    .disabled(true)
                Spacer()
            }
        }
        
    }
}


// MARK: - Preview
#Preview {
    GraphTemplateEditor_EmptySelection()
}
