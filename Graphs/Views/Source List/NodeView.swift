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
    @Bindable var node: Node
    
    private var isSelected: Bool {
        sourceListVM.selection.contains(node.id)
    }
    
    @FocusState private var isFocused: Bool
    
    init(_ sourceListVM: SourceListViewModel, _ node: Node) {
        self.sourceListVM = sourceListVM
        self.node = node
    }
    
    var body: some View {
        HStack {
            FolderLabel(isSelected)
            TextField("", text: $node.name)
        }
        .focused($isFocused)
        .draggable(DropItem(node))
        .onChange(of: isFocused, {
            print("focused changed to: \(isFocused)")
        })
        
        .dropDestination(for: DropItem.self, action: { items, location in
            sourceListVM.drop(items: items, onto: node)
            return true
        })
        .contextMenu {
            Button_newFolder(withParent: node)
            Button_DeleteSelectedNode()
            Button_ImportDirectory()
        }
        .alert(isPresented: $sourceListVM.presentURLImportError) { importAlert }
    }
    
    
    // MARK: - Buttons
    
    @ViewBuilder
    private func Button_newFolder(withParent parentNode: Node?) -> some View {
        Button(UIStrings.createNewFolder) {
            sourceListVM.createEmptyNode(withParent: parentNode)
        }
    }
    
    
    @ViewBuilder
    private func Button_DeleteSelectedNode() -> some View {
        Button("Delete \(sourceListVM.selection.count) Folders") {
            sourceListVM.deleteSelectedNodes()
        }
    }
    
    @ViewBuilder
    private func Button_ImportDirectory() -> some View {
        Button(UIStrings.importFolders) {
            sourceListVM.importDirectories(into: self.node)
        }
    }
    
    
    
    // MARK: - Alerts
    private var importAlert: Alert {
        Alert(title: Text("Import Error"), message: Text("Files must be imported into an existing Group"))
    }
    
}

#Preview {
    NodeView(AppController().sourceListVM,
             Node(url: nil))
}
