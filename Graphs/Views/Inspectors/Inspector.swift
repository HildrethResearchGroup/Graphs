//
//  Inspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct Inspector: View {
    var viewModel: InspectorViewModel
    
    @AppStorage("selectedTab_Inspector") private var selectedTab: HNTab = .folder
    
    @AppStorage("TextInspector_useNumberedText") private var useNumberedText: Bool = false
    
    init(_ viewModel: InspectorViewModel) {
        self.viewModel = viewModel
    }

    
    var body: some View {
         VStack {
             Tabs
             TabContent(for: selectedTab)
         }
        .frame(minWidth: 330, maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private var OriginalTab: some View {
        TabView {
             DataItemsInspector(viewModel.dataItemsVM)
                 .tabItem { Image(systemName: "document") }
             GraphTemplateInspector(viewModel.graphTemplateInspectorVM)
                 //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                 //.tabItem { Text("􁂥") }
                 .tabItem { Image(systemName: "chart.xyaxis.line") }

             ParserInspector(viewModel)
                 //.frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                 //.tabItem { Text("􀋱") }
                .tabItem { Image(systemName: "list.bullet") }
             TextInspector(viewModel.textInspectorVM)
                 .tabItem { Text("T") }
             TableInspector(viewModel.tableInspectorVM)
                 //.tabItem { Text("􀏣") }
                 .tabItem { Image(systemName: "tablecells") }
        }
    }
    
    
    private var Tabs: some View {
        HStack {
            Spacer()
            ForEach(HNTab.allCases) { tab in
                TabIcon(for: tab)
                    .onTapGesture(count: 1) {
                        selectedTab = tab
                    }
            }
            Spacer()
            
        }
    }
    
    
    private func TabIcon(for tab: HNTab) -> some View {
        HStack {
            switch tab {
            case .folder:
                Image(systemName: "folder")
                    .help(viewModel.toolTip_Node)
                    .foregroundStyle(foreground(for: .folder))
            case .dataItem:
                Image(systemName: "text.document")
                    .help(viewModel.toolTip_DataItem)
                    .foregroundStyle(foreground(for: .dataItem))
            case .graphTemplate:
                Image(systemName: "chart.xyaxis.line")
                    .help(viewModel.toolTip_GraphTemplate)
                    .foregroundStyle(foreground(for: .graphTemplate))
            case .parserSettings:
                Image(systemName: "list.bullet")
                    .help(viewModel.toolTip_ParserSettings)
                    .foregroundStyle(foreground(for: .parserSettings))
            case .text:
                Text("T")
                    .help(viewModel.toolTip_TextInspector)
                    .foregroundStyle(foreground(for: .text))
                    .contextMenu() {
                        Button_simpleSelector
                        Button_numberedSelector
                    }
                    .frame(alignment: .trailing)
            case .table:
                Image(systemName: "tablecells")
                    .help(viewModel.toolTip_TableInspector)
                    .foregroundStyle(foreground(for: .table))
            }
        }.font(.title2)
    }
    
    
    private func TabContent(for tab: HNTab) -> some View {
        VStack {
            switch selectedTab {
            case .folder: NodesInspectorView(viewModel.nodeInspectorVM)
            case .dataItem: DataItemsInspector(viewModel.dataItemsVM)
            case .graphTemplate: GraphTemplateInspector(viewModel.graphTemplateInspectorVM)
            case .parserSettings: ParserInspector(viewModel)
            case .text: TextInspector(viewModel.textInspectorVM)
            case .table: TableInspector(viewModel.tableInspectorVM)
            }
        }
    }
    
    
    private func foreground(for tab: HNTab) -> Color {
        if selectedTab == tab {
            return .blue
        } else {
            return .primary
        }
    }
    
    
    private enum HNTab: Int, CaseIterable, Identifiable, Hashable, Codable {
        var id: Self { self }
        
        case folder = 1
        case dataItem
        case graphTemplate
        case parserSettings
        case text
        case table
    }
    
    
    @ViewBuilder
    private var Button_simpleSelector: some View {
        if useNumberedText {
            Button(action: {useNumberedText = false}) {
                Text("Simple")
            }
        } else {
            Button(action: {useNumberedText = false}) {
                Text("Simple")
                    .foregroundStyle(.blue)
            }
        }
    }
    
    
    @ViewBuilder
    private var Button_numberedSelector: some View {
        if useNumberedText {
            Button(action: {useNumberedText = true}) {
                Text("Numbered")
                    .foregroundStyle(.blue)
            }
        } else {
            Button(action: {useNumberedText = true}) {
                Text("Numbered")
            }
        }

    }
}


// MARK: - Preview
#Preview {
    @Previewable
    @State var appController = AppController()
    Inspector(appController.inspectorVM)
}
