//
//  TextInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct TextInspector: View {
    @Bindable private var viewModel: TextInspectorViewModel

    init(_ viewModel: TextInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // HeaderView
            // Divider()
            
            TabContent
            Spacer()
        }
        .onAppear { viewModel.viewIsVisable = true }
        .onDisappear { viewModel.viewIsVisable = false }
        
    }
    
    // MARK: - SubViews
    private var HeaderView: some View {
        VStack {
            Text("Parser: \(viewModel.parserSettings?.name ?? "")")
            Picker_stringEncodingType
            Picker_newLineType
        }
    }
    
    
    private var TabContent: some View {
        VStack {
            if viewModel.processingState == .upToDate {
                TabView {
                    Tab(content: { Text_Simple },
                        label: { Text("Simple") })
                    Tab(content: { Text_numbered },
                        label: { Text("Numbered") })
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    
    // MARK: - Text Views
    private var Text_Simple: some View {
        TextEditor(text: Binding.constant(viewModel.content))
            .lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    private var Text_numbered: some View {
        TextEditor(text: Binding.constant(viewModel.combinedLineNumbersAndContent))
            .lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
        
    }
    
    
    // MARK: - Pickers
    private var Picker_newLineType: some View {
        Picker("New Line:", selection: $viewModel.newLineType) {
            ForEach(NewLineType.allCases) { nextLineType in
                Text(nextLineType.name)
            }
        }
        .help(NewLineType.toolTip)
    }
    
    private var Picker_stringEncodingType: some View {
        Picker("Encoding:", selection: $viewModel.stringEncodingType) {
            ForEach(StringEncodingType.primaryEncodings) { nextEncoding in
                Text(nextEncoding.rawValue)
            }
            Divider()
            ForEach(StringEncodingType.secondaryEncodings) { nextEncoding in
                Text(nextEncoding.rawValue)
            }
        }
        .help(StringEncodingType.toolTip)
    }
    
}


// MARK: - Preview
#Preview {
    let controller = DataController(withDelegate: nil)
    let viewModel = TextInspectorViewModel(controller)
    TextInspector(viewModel)
}


