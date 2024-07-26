//
//  GraphTemplateEditor_EmptySelection.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData

struct GraphTemplateEditor_EmptySelection: View {
    
    @State var graphController = GraphController()
    
    @State var name: String = ""
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        Form() {
            TextField("Name:", text: $name)
            GraphViewRepresentable(graphController: graphController)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.formStyle(.grouped)
        
    }
}


// MARK: - Preview
#Preview {
    GraphTemplateEditor_EmptySelection()
}
