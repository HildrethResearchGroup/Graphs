//
//  TextInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct TextInspector: View {
    @State private var viewModel: LineNumberViewModel
    
    @AppStorage("textInspectorIsSimple") private var textInspectorIsSimple = false
    
    @State private var newLineType: NewLineType
    @State private var stringeEncodingType: StringEncodingType
    
    init(_ viewModel: LineNumberViewModel) {
        self._viewModel = State(initialValue: viewModel)
        self._newLineType = State(initialValue: viewModel.newLineType ?? .CRLF)
        self._stringeEncodingType = State(initialValue: viewModel.stringEncodingType ?? .ascii)
    }
    
    
    var body: some View {
        VStack(alignment:.leading ) {
            
            Heading
                .font(.title3)
            
            TabView {
                Tab("Simple", systemImage: "house") {
                    simpleStringView
                }
                
                Tab("Lines", systemImage: "house") {
                    SimpleTextWithLineNumbers(viewModel.combinedLineNumbersAndContent)
                }
            }
        }
    }
    
    
    @ViewBuilder
    var simpleStringView: some View {
        Text(viewModel.content)
    }
    
    @ViewBuilder
    var Heading: some View {
        HStack {
            Text("Example: \(viewModel.dataItem?.name ?? "")")
            Spacer()
            Button(action: viewModel.updateState, label: {Image(systemName: "arrow.clockwise")})
        }
    }
    
    
    @ViewBuilder
    func ParsingOptions() -> some View {
        
        VStack {
            Picker("New Line", selection: $newLineType) {
                ForEach(NewLineType.allCases) { nextLineType in
                    Text(nextLineType.name)
                }
            }
            .help(NewLineType.toolTip)
            .onChange(of: newLineType) {
                viewModel.newLineType = newLineType
            }
            
            Picker("Encoding", selection: $stringeEncodingType) {
                ForEach(StringEncodingType.allCases) { nextEncoding in
                    Text(nextEncoding.rawValue)
                }
            }
            .help(StringEncodingType.toolTip)
            .onChange(of: stringeEncodingType) {
                viewModel.stringEncodingType = stringeEncodingType
            }
        }
        .onAppear {
            updateState()
        }
    }
    
    private func updateState() {
        if let newLineType = viewModel.newLineType {
            self.newLineType = newLineType
        }
        
        if let stringEncodingType = viewModel.stringEncodingType {
            self.stringeEncodingType = stringEncodingType
        }
    }
    
    
    
}


// MARK: - Preview
#Preview {
    let dataItem = DataItem(url: URL.init(filePath: ""))
    let viewModel = LineNumberViewModel(dataItem)
    TextInspector(viewModel)
}


