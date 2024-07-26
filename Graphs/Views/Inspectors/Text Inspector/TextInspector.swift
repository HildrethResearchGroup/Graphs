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
            Form() {
                Toggle("Simplified", isOn: $textInspectorIsSimple)
                    .help("Some data files have hidden characters that cause extra wrapping.  View your data using the Simplified view to verify that the lines numbers are correct.")
                ParsingOptions()
            }
            .formStyle(.grouped)
            .frame(maxHeight: 135)
            
            if textInspectorIsSimple {
                SimpleTextWithLineNumbers(viewModel.combinedLineNumbersAndContent)
                    .frame(maxHeight: .infinity)
            } else {
                LineNumbersView(lineNumbers: viewModel.lineNumbers, content: viewModel.content)
                    .frame(maxHeight: .infinity)
            }
        }
        .onChange(of: dataItem) {
            viewModel.dataItem = dataItem
        }
    }
    
    
    @ViewBuilder
    func ParsingOptions() -> some View {
        VStack {
            Picker("New Line", selection: $viewModel.newLineType) {
                ForEach(NewLineType.allCases) { nextLineType in
                    Text(nextLineType.name)
                }
            }
            .help(NewLineType.toolTip)
            
            Picker("Encoding", selection: $viewModel.stringEncodingType) {
                ForEach(StringEncodingType.allCases) { nextEncoding in
                    Text(nextEncoding.rawValue)
                }
            }
            .help(StringEncodingType.toolTip)
        }
    }
    
}


// MARK: - Preview
 #Preview {
     TextInspector(dataItem: DataItem(url: Bundle.main.url(forResource: "diluteHF - 3 - Volts", withExtension: "dat") ?? URL(fileURLWithPath: ""), node: Node(url: nil, parent: nil)))
 }
 

