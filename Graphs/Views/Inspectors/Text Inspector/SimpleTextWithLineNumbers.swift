//
//  SimpleTextWithLineNumbers.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/11/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct SimpleTextWithLineNumbers: View {
    var combinedLineNumbersAndContent: String
    
    init(_ combinedLineNumbersAndContent: String) {
        self.combinedLineNumbersAndContent = combinedLineNumbersAndContent
    }
    
    var body: some View {
        ScrollView {
            Text(combinedLineNumbersAndContent)
        }
        
    }
}

#Preview {
    SimpleTextWithLineNumbers("1:\tHello.\n2:\tHow are you?  This will be a long line to make sure the line numbers line up properly.  Don't stop typing.\n3:\tThird Line")
}
