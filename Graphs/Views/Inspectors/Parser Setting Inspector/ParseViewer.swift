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
    
    
    @AppStorage("selectedTab_ParseViewer") private var selectedTab: ParseViewTab = .simple
    
    init(_ tableViewModel: TableInspectorViewModel, _ textViewModel: TextInspectorViewModel) {
        self.tableViewModel = tableViewModel
        self.textViewModel = textViewModel
    }
    
    var body: some View {
        VStack {
            Tabs
            TabContent
        }
        .background(.white)
        .onAppear {
            textViewModel.parseInpsectorViewIsVisible = true
            tableViewModel.viewIsVisable = true
        }
        .onDisappear {
            textViewModel.parseInpsectorViewIsVisible = false
            tableViewModel.viewIsVisable = false
        }
    }
    
    @ViewBuilder
    private var OriginalTabView: some View {
        TabView {
            Tab("Simple", systemImage: "text.document") {
                Text_Simple
                    .onAppear { textViewModel.parseInpsectorViewIsVisible = true }
                    .onDisappear { textViewModel.parseInpsectorViewIsVisible = false }
            }
            
            Tab("Numbered", systemImage: "list.number") {
                Text_numbered
                    .onAppear { textViewModel.parseInpsectorViewIsVisible = true }
                    .onDisappear { textViewModel.parseInpsectorViewIsVisible = false }
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
        //.lineLimit(100)
            .frame(maxWidth: .infinity)
            .monospaced()
            .lineSpacing(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    private var Text_numbered: some View {
        TextEditor(text: Binding.constant(textViewModel.combinedLineNumbersAndContent))
        //.lineLimit(100)
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


// MARK: - Custom Tab
extension ParseViewer {
    
    private var Tabs: some View {
        HStack {
            Spacer()
            HStack {
                ForEach(ParseViewTab.allCases) { tab in
                    TabIcon(for: tab)
                        .onTapGesture(count: 1) {
                            selectedTab = tab
                        }
                }
            }
            //.padding(5)
            //.background(in: .buttonBorder)
            //.backgroundStyle(.thinMaterial)
            
            Spacer()
            
        }
    }
    
    
    private var TabContent: some View {
        VStack {
            
            switch selectedTab {
            case .simple:
                Text_Simple
                    .onAppear { textViewModel.parseInpsectorViewIsVisible = true }
                    .onDisappear { textViewModel.parseInpsectorViewIsVisible = false }
            case .numbered:
                Text_numbered
                    .onAppear { textViewModel.parseInpsectorViewIsVisible = true }
                    .onDisappear { textViewModel.parseInpsectorViewIsVisible = false }
            case .table:
                TableInspector(tableViewModel)
                    .onAppear { tableViewModel.viewIsVisable = true }
                    .onDisappear { tableViewModel.viewIsVisable = false }
            }
        }
    }
    
    private func TabIcon(for tab: ParseViewTab) -> some View {
        HStack {
            switch tab {
            case .simple:
                Text("Simple")
                    .foregroundStyle(foreground(for: .simple))
            case .numbered:
                Text("Numbered")
                    .foregroundStyle(foreground(for: .numbered))
            case .table:
                Text("Table")
                    .foregroundStyle(foreground(for: .table))
            }
        }
    }
    
    private func foreground(for tab: ParseViewTab) -> Color {
        if selectedTab == tab {
            return .blue
        } else {
            return .primary
        }
    }
    
    private func background(for tab: ParseViewTab) -> Color {
        if selectedTab == tab {
            return .red
        } else {
            return .clear
        }
    }
    
    private enum ParseViewTab: Int, CaseIterable, Identifiable, Hashable, Codable {
        var id: Self { self }
        case simple
        case numbered
        case table
    }
}
