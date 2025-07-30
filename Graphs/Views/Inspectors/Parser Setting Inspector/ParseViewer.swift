//
//  ParseViewer.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/30/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ParseViewer: View {
    
    
    var body: some View {
        TabView {
            Tab("Simple", image: "") {
                Text("Simple")
            }
            Tab("Numbered", image: "") {
                Text("Numbered")
            }
            Tab("Table", image: "") {
                Text("Table")
            }
        }
    }
}

#Preview {
    ParseViewer()
}
