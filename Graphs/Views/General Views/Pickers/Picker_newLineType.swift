//
//  Picker_newLineType.swift
//  Graphs
//
//  Created by Owen Hildreth on 8/22/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct Picker_newLineType: View {
    @Binding var newLineType: NewLineType
    
    init(_ newLineType: Binding<NewLineType>) {
        self._newLineType = newLineType
    }
    
    var body: some View {
        Picker("New Line:", selection: $newLineType) {
            ForEach(NewLineType.allCases) { nextLineType in
                Text(nextLineType.name)
            }
        }
        .help(NewLineType.toolTip)
    }
}

#Preview {
    @Previewable
    @State var newLineType: NewLineType = .LFCR
    Picker_newLineType($newLineType)
}
