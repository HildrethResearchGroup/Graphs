//
//  NilTextField.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/25/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct NilTextField: View {
    var title: String
    
    @State private var content: String = ""
    
    init(_ title: String = "") {
        self.title = title
    }
    
    var body: some View {
        TextField(title, text: $content)
            .disabled(true)
    }
}

#Preview {
    NilTextField()
}
