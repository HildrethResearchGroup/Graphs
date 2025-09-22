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
    
    @AppStorage("TextInspector_useNumberedText") private var useNumberedText: Bool = false
    //@State private var useNumberedText: Bool = false
    
    @AppStorage("TextInspector_useLineLimit") private var useLineLimit: Bool = false

    init(_ viewModel: TextInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if useNumberedText {
                Text_Numbered
                    .onAppear { viewModel.textInspectorViewIsVisable = true }
                    .onDisappear { viewModel.textInspectorViewIsVisable = false }
            } else {
                Text_Simple
                    .onAppear { viewModel.textInspectorViewIsVisable = true }
                    .onDisappear { viewModel.textInspectorViewIsVisable = false }
            }
        }
        .frame(maxWidth: .infinity)
        .backgroundStyle(.white)
        .background(.white)
        
    }
    

  
    
    // MARK: - Text Views
    private var Text_Simple: some View {
        TextEditor(text: Binding.constant(viewModel.content))
            //.lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
            .selectionDisabled(false)
    }
    
    private var Text_Numbered: some View {
        TextEditor(text: Binding.constant(viewModel.combinedLineNumbersAndContent))
            //.lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
            .selectionDisabled(false)
    }
    
    var lineLimit: Int {
        if useLineLimit {
            return 100
        } else {
            return .max
        }
    }
}



// MARK: - Preview
#Preview {
    let controller = AppController()
    TextInspector(controller.inspectorVM.textInspectorVM)
}
