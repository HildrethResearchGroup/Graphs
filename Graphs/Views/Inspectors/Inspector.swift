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
                    .font(.title2)
                    .foregroundStyle(foreground(for: .folder))
            case .dataItem:
                Image(systemName: "text.document")
                    .font(.title2)
                    .foregroundStyle(foreground(for: .dataItem))
            case .graphTemplate:
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
                    .foregroundStyle(foreground(for: .graphTemplate))
            case .parserSettings:
                Image(systemName: "list.bullet")
                    .font(.title2)
                    .foregroundStyle(foreground(for: .parserSettings))
            case .text:
                Text("T")
                    .font(.title2)
                    .foregroundStyle(foreground(for: .text))
            case .table:
                Image(systemName: "tablecells")
                    .font(.title2)
                    .foregroundStyle(foreground(for: .table))
            }
        }
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
}


// MARK: - Preview
#Preview {
    @Previewable
    @State var appController = AppController()
    Inspector(appController.inspectorVM)
}
