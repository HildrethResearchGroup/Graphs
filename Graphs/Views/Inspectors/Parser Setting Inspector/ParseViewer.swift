//
//  ParseViewer.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/30/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct ParseViewer: View {
    @Bindable var tableViewModel: TableInspectorViewModel
    @Bindable var textViewModel: TextInspectorViewModel
    
    init(_ tableViewModel: TableInspectorViewModel, _ textViewModel: TextInspectorViewModel) {
        self.tableViewModel = tableViewModel
        self.textViewModel = textViewModel
    }
    
    var body: some View {
    
        TabView {
            Tab("Simple", systemImage: "text.document") {
                Text_Simple
                    .onAppear { textViewModel.viewIsVisable = true }
                    .onDisappear { textViewModel.viewIsVisable = false }
            }
            
            Tab("Numbered", systemImage: "list.number") {
                Text_numbered
                    .onAppear { textViewModel.viewIsVisable = true }
                    .onDisappear { textViewModel.viewIsVisable = false }
            }
            
            Tab("Table", systemImage: "tablecells") {
                TableInspector(tableViewModel)
                    .onAppear { tableViewModel.viewIsVisable = true }
                    .onDisappear { tableViewModel.viewIsVisable = false }
            }
        }
    }
    
    
    // MARK: - Text Views
    private var Text_Simple: some View {
        TextEditor(text: Binding.constant(textViewModel.content))
            .lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    private var Text_numbered: some View {
        TextEditor(text: Binding.constant(textViewModel.combinedLineNumbersAndContent))
            .lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
        
    }
}

#Preview {
    @Previewable
    @State var controller: AppController = AppController()
    ParseViewer(controller.inspectorVM.tableInspectorVM, controller.inspectorVM.textInspectorVM)
}
