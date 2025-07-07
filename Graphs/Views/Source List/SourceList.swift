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
        VStack(alignment: .leading) {
            List(selection: $sourceListVM.selection) {
                OutlineGroup(sourceListVM.rootNodes, id: \.self, children: \.subNodes) { nextNode in
                    NodeContent(nextNode)
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
            }.padding(.leading, 5)
            
        }
        .contextMenu {
            Button_newFolder(withParent: nil)
            Button_deselectNodes()
        }
        .alert(isPresented: $sourceListVM.presentURLImportError) { return importAlert }
    }
    
    
    // MARK: - Primary Content
    @ViewBuilder
    func NodeContent(_ node: Node) -> some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.secondary)
            Text(node.name)
        }
        .draggable(node.localID)
            .dropDestination(for: UUID.self, action: { items, location in
                sourceListVM.drop(uuids: items, onto: node)
                print("Drop \(items)")
                return true
            })
        .contextMenu {
            Button_newFolder(withParent: node)
            Button_DeleteSelectedNode()
        }
        .dropDestination(for: URL.self) { urls, _  in
            
            let success = sourceListVM.importURLs(urls, intoNode: node)
            return success
        }
        
        .alert(isPresented: $sourceListVM.presentURLImportError) { importAlert }
        
    }
          
    
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
    @ViewBuilder
    private func Button_newFolder(withParent parentNode: Node?) -> some View {
        Button("Create New Folder") {
            sourceListVM.createEmptyNode(withParent: parentNode)
        }
    }
    
    
    @ViewBuilder
    private func Button_importDirectories() -> some View {
        Button("Import Folders") {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = true
            panel.canCreateDirectories = false
            panel.allowsMultipleSelection = true
            panel.allowedContentTypes = [.dgraph ?? .data, .directory, .gparser ?? .json, .data, .delimitedText]
            
            if panel.runModal() == .OK {
                let urls = panel.urls
                _ = sourceListVM.importURLs(urls)
            }
        }
    }
    
    @ViewBuilder
    private func Button_importFile() -> some View {
        Button("Import Data") {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.canCreateDirectories = false
            panel.allowsMultipleSelection = true
            panel.allowedContentTypes = [.data, .delimitedText]
            
            if panel.runModal() == .OK {
                let urls = panel.urls
                _ = sourceListVM.importURLs(urls)
            }
        }
        .help(sourceListVM.toolTip_importFile)
        .disabled(sourceListVM.disabledButton_importFile)
        
        
    }
    
    @ViewBuilder
    private func Button_importParserSettings() -> some View {
        Button("Import Parser") {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.canCreateDirectories = false
            panel.allowsMultipleSelection = true
            panel.allowedContentTypes = [.gparser ?? .json]
            
            if panel.runModal() == .OK {
                let urls = panel.urls
                _ = sourceListVM.importURLs(urls)
            }
        }
    }
    
    @ViewBuilder
    private func Button_importGraphTemplate() -> some View {
        Button("Import Graph Template") {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.canCreateDirectories = false
            panel.allowsMultipleSelection = true
            panel.allowedContentTypes = [.dgraph ?? .data]
            
            if panel.runModal() == .OK {
                let urls = panel.urls
                _ = sourceListVM.importURLs(urls)
            }
        }
    }
    
    
    
    @ViewBuilder
    private func Button_DeleteSelectedNode() -> some View {
        Button("Delete \(sourceListVM.selection.count) Folders") {
            sourceListVM.deleteSelectedNodes()
        }
    }
    
    @ViewBuilder
    private func Button_DeleteSelectedDataItems() -> some View {
        Button("Delete DataItems") {
            
        }
    }
    
    
    @ViewBuilder
    private func Button_deselectNodes() -> some View {
        Button("Clear Selection") {
            sourceListVM.deselectNodes()
        }
    }
    
    
    // MARK: - Alerts
    private var importAlert: Alert {
        Alert(title: Text("Import Error"), message: Text("Files must be imported into an existing Group"))
    }
}

// MARK: - Preview
/*
 #Preview {
     SourceList()
 }
 */
