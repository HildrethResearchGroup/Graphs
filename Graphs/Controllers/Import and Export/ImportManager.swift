//
//  ImportManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation

@MainActor
class ImportManager {
    var dataController: DataController
    var selectionManager: SelectionManager
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
    
    
    // MARK: - Creating new Nodes
    /// Creates a new Node
    ///
    /// Creates a new node without the caller having to know the currenly selected node (if any)
    func newNode() {
        if dataController.selectedNodes.count == 1 {
            let selectedNode = dataController.selectedNodes.first
            
            newNode(withParent: selectedNode)
        } else {
            newNode(withParent: nil)
        }
    }
    
    
    /// Creates a new Node with the target parent Node
    func newNode(withParent parentNode: Node?) {
        dataController.createEmptyNode(withParent: parentNode)
    }
    
    
    // MARK: - Checking Allowing Import
    /// Check if data files can be imported
    ///
    /// Only one node can be selected when importing data files.  DataItem requires a node so it can be properly stored and located.  However, it is isn't clear where to place an importing DataItem if multiple Nodes are selected.  So only one node should be allowed.
    private func shouldAllowDataFileImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        switch numberOfNodes {
        case 0: return false
        case 1: return true
        default: return false
        }
    }
    
    
    /// Check if Graph Template files can be imported
    ///
    /// At this time, we don''t import Graph Template files if multiple Nodes are selected.
    private func shouldAllGraphTemplatesImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        if numberOfNodes > 1 {
            return false
        } else {
            return true
        }
    }
    
    
    /// Check if Parser Settings files can be imported
    ///
    /// At this time, we don''t import Graph Template files if multiple Nodes are selected.
    private func shouldAllowParserSettingsImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        if numberOfNodes > 1 {
            return false
        } else {
            return true
        }
    }
    
    
    // MARK: - Importing Files
    /// Imports Data Files into the selected Node
    func importDataFiles() -> Bool {
        if !shouldAllowDataFileImport() {
            return false
        }
        
        guard let parentNode = dataController.selectedNodes.first else {return false}
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.data, .delimitedText]
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            let success = dataController.importURLs(urls, intoNode: parentNode)
            
            return success
        } else {
            return false
        }
    }
    
    
    /// Import Directories into the selected nodes
    func importDirectories() -> Bool {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.dgraph ?? .data, .directory, .gparser ?? .json, .data, .delimitedText, .text]
        
        let parentNode = dataController.selectedNodes.first
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            let success = dataController.importURLs(urls, intoNode: parentNode)
            
            return success
        } else {
            return false
        }
    }
    
    
    func importParserSettings() -> Bool {
        
        if !shouldAllowParserSettingsImport() {
            return false
        }
        
        let parentNode = dataController.selectedNodes.first
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.gparser ?? .json]
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            let success = dataController.importURLs(urls, intoNode: parentNode)
            return success
        } else {
            return false
        }
    }
    
    
    
    func importGraphTemplate() -> Bool {
        
        if !shouldAllGraphTemplatesImport() {
            return false
        }
        
        let parentNode = dataController.selectedNodes.first
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.dgraph ?? .data]
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            let success = dataController.importURLs(urls, intoNode: parentNode)
            return success
        } else {
            return false
        }
    }
    
    
    
}


extension Notification.Name {
    static var importFiles = Notification.Name("importFiles")
}
