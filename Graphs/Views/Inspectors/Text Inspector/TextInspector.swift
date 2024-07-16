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
    
    @State private var viewModel: LineNumberViewModel
    
    @AppStorage("textInspectorIsSimple") private var textInspectorIsSimple = false
    
    
    init(dataItem: DataItem?) {
        self.dataItem = dataItem
        self._viewModel = State(initialValue: LineNumberViewModel(dataItem))
    }
    
    var body: some View {
        VStack(alignment:.leading ) {
            HStack {
                ParsingOptions()
                Toggle("Simplified", isOn: $textInspectorIsSimple)
                    .help("Some data files have hidden characters that cause extra wrapping.  View your data using the Simplified view to verify that the lines numbers are correct.")
            }
            if textInspectorIsSimple {
                SimpleTextWithLineNumbers(viewModel.combinedLineNumbersAndContent)
            } else {
                LineNumbersView(lineNumbers: viewModel.lineNumbers, content: viewModel.content)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: dataItem) {
            viewModel.dataItem = dataItem
        }
        
    }
    
    
    @ViewBuilder
    func ParsingOptions() -> some View {
        HStack {
            Picker("New Line", selection: $viewModel.newLineType) {
                ForEach(NewLineType.allCases) { nextLineType in
                    Text(nextLineType.name)
                }
            }
            .frame(width: 120)
            .help(NewLineType.toolTip)
            
            Picker("Encoding", selection: $viewModel.stringEncodingType) {
                ForEach(StringEncodingType.allCases) { nextEncoding in
                    Text(nextEncoding.rawValue)
                }
            }
            .frame(minWidth: 150, maxWidth: 200)
            .help(StringEncodingType.toolTip)
        }
    }
    
}



 #Preview {
     TextInspector(dataItem: DataItem(url: Bundle.main.url(forResource: "diluteHF - 3 - Volts", withExtension: "dat") ?? URL(fileURLWithPath: ""), node: Node(url: nil, parent: nil)))
 }
 

