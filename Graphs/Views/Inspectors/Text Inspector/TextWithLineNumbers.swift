//
//  TextWithLineNumbers.swift
//  LineNumbers
//
//  Created by Owen Hildreth on 6/28/24.
//

import SwiftUI

struct TextWithLineNumbers: View {
    var lineNumbers: String
    var content: String
    
    var body: some View {
        ScrollView([.vertical]) {
            HStack(alignment: .top) {
                Text(lineNumbers)
                Divider()
                ScrollView([.horizontal]) {
                    Text(content)
                        .textSelection(.enabled)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .background(.white)
    }

    
}



#Preview {
    TextWithLineNumbers(lineNumbers: "1\n2\n3", content: "Hello.\nHow are you?  This will be a long line to make sure the line numbers line up properly.  Don't stop typing.\nThird Line")
}
