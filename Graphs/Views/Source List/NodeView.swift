//
//  NodeView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/12/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct NodeView: View {
    @Bindable var sourceListVM: SourceListViewModel
    var node: Node
    
    init(_ sourceListVM: SourceListViewModel, _ node: Node) {
        self.sourceListVM = sourceListVM
        self.node = node
    }
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.secondary)
            Text(node.name)
        }
        .draggable(node.localID)
        .dropDestination(for: DropItem.self, action: { items, location in
            
            sourceListVM.drop(items: items, onto: node)
            return true
        })
        .contextMenu {
            Button_newFolder(withParent: node)
            Button_DeleteSelectedNode()
        }
        .alert(isPresented: $sourceListVM.presentURLImportError) { importAlert }
    }
    
    // MARK: - Buttons
    @ViewBuilder
    private func Button_newFolder(withParent parentNode: Node?) -> some View {
        Button("Create New Folder") {
            sourceListVM.createEmptyNode(withParent: parentNode)
        }
    }
    
    
    @ViewBuilder
    private func Button_DeleteSelectedNode() -> some View {
        Button("Delete \(sourceListVM.selection.count) Folders") {
            sourceListVM.deleteSelectedNodes()
        }
    }
    
    
    // MARK: - Alerts
    private var importAlert: Alert {
        Alert(title: Text("Import Error"), message: Text("Files must be imported into an existing Group"))
    }
    
}

#Preview {
    NodeView(SourceListViewModel(DataController(withDelegate: nil),
                                            SelectionManager()),
             Node(url: nil))
}
