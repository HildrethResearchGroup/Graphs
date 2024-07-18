//
//  SourceList.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct SourceList: View {
    @Bindable var sourceListVM: SourceListViewModel
    
    var body: some View {
        List(selection: $sourceListVM.selection) {
            OutlineGroup(sourceListVM.rootNodes, id: \.self, children: \.subNodes) { nextNode in
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.secondary)
                    Text(nextNode.name)
                }
                .contextMenu {
                    Button_newFolder(withParent: nextNode)
                    Button_DeleteSelectedNode()
                }
                .dropDestination(for: URL.self) { urls, _  in
                    let success = sourceListVM.importURLs(urls, intoNode: nextNode)
                    return success
                }
                .alert(isPresented: $sourceListVM.presentURLImportError) { importAlert }
            }
        }
        .contextMenu {
            Button_newFolder(withParent: nil)
            Button("Deselect") {
                sourceListVM.deselectNodes()
            }
        }
        .dropDestination(for: URL.self) { urls, _  in
            let success = sourceListVM.importURLs(urls, intoNode: nil)
            return success
        }
        .alert(isPresented: $sourceListVM.presentURLImportError) { return importAlert }
        
    }
    
    
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
    
    private var importAlert: Alert {
        Alert(title: Text("Import Error"), message: Text("Files must be imported into an existing Group"))
    }
}
