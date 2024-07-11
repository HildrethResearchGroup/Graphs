//
//  TextInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct TextInspector: View {
    var dataItem: DataItem?
    
    @State private var provider: LineNumberProvider
    
    init(dataItem: DataItem?) {
        self.dataItem = dataItem
        self._provider = State(initialValue: LineNumberProvider(dataItem))
    }
    
    var body: some View {
        TextWithLineNumbers(lineNumbers: provider.lineNumbers, content: provider.content)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


 #Preview {
     TextInspector(dataItem: DataItem(url: Bundle.main.url(forResource: "diluteHF - 3 - Volts", withExtension: "dat") ?? URL(fileURLWithPath: ""), node: Node(url: nil, parent: nil)))
 }
 

