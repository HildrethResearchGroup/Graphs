//
//  GraphTemplateEditor_EmptySelection.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI
import SwiftData

struct GraphTemplateEditor_EmptySelection: View {
    @State var name: String = ""
    
    private let width = 100.0
    private let fontType: Font = .headline
    
    var body: some View {
        Form() {
            TextField("Name:", text: $name)
                .disabled(true)
            HStack {
                Text("Filepath:")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .formStyle(.grouped)
        .padding(.horizontal, -20)
    }
}


// MARK: - Preview
#Preview {
    GraphTemplateEditor_EmptySelection()
}
