//
//  SourceList.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct SourceList: View {
    @Bindable var sourceListVM: SourceListViewModel
    
    init(_ sourceListVM: SourceListViewModel) {
        self.sourceListVM = sourceListVM
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List(selection: $sourceListVM.selection) {
                OutlineGroup(sourceListVM.rootNodes, id: \.id, children: \.children) { nextNode in
                    NodeView(sourceListVM, nextNode)
                }
            }
            
            Spacer()
            
             .dropDestination(for: URL.self) { urls, _  in
                 let success = sourceListVM.importURLs(urls, intoNode: nil)
                 return success
             }
             
                
            HStack {
                Menu_plus()
                Menu_minus()
            }
            .padding(.leading, 5)
        }
        .contextMenu {
            Button_newFolder(withParent: nil)
            Button_deselectNodes()
        }
        .alert(isPresented: $sourceListVM.presentURLImportError) { return importAlert }
    }
    
    
    /*
     // MARK: - Primary Content
     @ViewBuilder
     func NodeContent(_ node: Node) -> some View {
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
     */
    
          
    
    // MARK: - Menu Buttons
    @ViewBuilder
    private func Menu_plus() -> some View {
        Menu {
            Button_newFolder(withParent: nil)
            Button_importDirectories()
            Button_importFile()
            Button_importGraphTemplate()
            Button_importParserSettings()
        } label: {
            Image(systemName: "plus")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 20, height: 25)
        .menuIndicator(.hidden)
    }
    
    
    @ViewBuilder
    private func Menu_minus() -> some View {
        Menu{
            Button_DeleteSelectedNode()
        } label: {
            Image(systemName: "minus")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 20, height: 25)
        .menuIndicator(.hidden)
    }
    
    
    
    // MARK: - Content Buttons
    // New Folder
    @ViewBuilder
    private func Button_newFolder(withParent parentNode: Node?) -> some View {
        Button(UIStrings.createNewFolder) {
            sourceListVM.createEmptyNode(withParent: parentNode)
        }
    }
    
    
    // Import Folders
    @ViewBuilder
    private func Button_importDirectories() -> some View {
        Button(UIStrings.importFolders) {
            sourceListVM.importDirectories()
        }
    }
    
    
    // Import Files
    @ViewBuilder
    private func Button_importFile() -> some View {
        Button(UIStrings.importFiles) {
            sourceListVM.importDataFiles()
        }
        .help(sourceListVM.toolTip_importFile)
        .disabled(sourceListVM.disabledButton_importFile)
        
        
    }
    
    
    // Import Parsers
    @ViewBuilder
    private func Button_importParserSettings() -> some View {
        Button(UIStrings.importParser) {
            sourceListVM.importParserSettings()
        }
    }
    
    
    // Import Graph Template
    @ViewBuilder
    private func Button_importGraphTemplate() -> some View {
        Button(UIStrings.importGraphTemplate) {
            sourceListVM.importGraphTemplate()
        }
    }
    
    
    // Delete Selected Nodes
    @ViewBuilder
    private func Button_DeleteSelectedNode() -> some View {
        Button("Delete \(sourceListVM.selection.count) Folders") {
            sourceListVM.deleteSelectedNodes()
        }
    }
    
    
    @ViewBuilder
    private func Button_deselectNodes() -> some View {
        Button(UIStrings.clearSelection) {
            sourceListVM.deselectNodes()
        }
    }
    
    
    // MARK: - Alerts
    private var importAlert: Alert {
        Alert(title: Text("Import Error"), message: Text("Files must be imported into an existing Group"))
    }
}

// MARK: - Preview

 #Preview {
     @Previewable
     @State var appController = AppController()
     SourceList(appController.sourceListVM)
 }
 
