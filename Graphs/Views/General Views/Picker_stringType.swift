//
//  Picker_stringType.swift
//  Graphs
//
//  Created by Owen Hildreth on 8/22/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct Picker_stringType: View {
    @Binding var stringEncondingType: StringEncodingType
    
    init(_ stringEncondingType: Binding<StringEncodingType>) {
        self._stringEncondingType = stringEncondingType
    }

    
    var body: some View {
        Picker("String Encoding", selection: $stringEncondingType) {
            ForEach(StringEncodingType.primaryEncodings) { nextEncoding in
                Text(nextEncoding.rawValue)
            }
            Divider()
            ForEach(StringEncodingType.secondaryEncodings) { nextEncoding in
                Text(nextEncoding.rawValue)
            }
        }
        //.frame(minWidth: 150, maxWidth: 200)
        .help(StringEncodingType.toolTip)
    }
}

#Preview {
    @Previewable
    @State var stringEncondingType: StringEncodingType = .ascii
    Picker_stringType($stringEncondingType)
}
