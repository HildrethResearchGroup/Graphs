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
    
    var toolTip_newNode: String {
        "Create new Folder"
    }
    
    
    /// Creates a new Node with the target parent Node
    func newNode(withParent parentNode: Node?) {
        dataController.createEmptyNode(withParent: parentNode)
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
    
    func shouldAllowDataFileImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        switch numberOfNodes {
        case 0: return false
        case 1: return true
        default: return false
        }
    }
    
    var toolTip_importDataFiles: String {
        let nodesCount = dataController.selectedNodes.count
        
        if nodesCount == 0 {
            return "Must select a folder to import data into"
        } else if nodesCount == 1 {
            guard let targetNode = dataController.selectedNodes.first else {
                return "Must select a folder to import data into"
            }
            
            return "Import data into \(targetNode.name)"
        } else {
            return "\(nodesCount)folders selected, data can only be imported into one folder"
        }
    }
    
    
    
    // MARK: - Import Directories
    /// Import Directories into the selected nodes
    ///
    /// Uses NSOpen Panel to select urls for importing
    func importAll() -> Bool {
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
    
    
    func shouldAllowAllImport() -> Bool {
        return true
    }
    
    var toolTip_importAll: String {
        let nodesCount = selectionManager.selectedNodeIDs.count
        if nodesCount == 0 {
            return "Import Directories"
        } else {
            guard let selectedNode = dataController.selectedNodes.first else {
                return "Import Directories"
            }
            return "Import Directores into \(selectedNode.name)"
        }
    }
    
    
    
    // MARK: - Import Parser Settings
    /// Import Parser Settings into Selected Node
    func importParserSettings() -> Bool {
        
        if !shouldAllowParserSettingsImport() {
            return false
        }
        
        let targetNode = dataController.selectedNodes.first
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.gparser ?? .json]
        
        if panel.runModal() == .OK {
            let urls = panel.urls
            let success = dataController.importURLs(urls, intoNode: targetNode)
            return success
        } else {
            return false
        }
    }

    
    
    /// Check if Parser Settings files can be imported
    ///
    /// At this time, we don't import Parser Settings files if multiple Nodes are selected.
    func shouldAllowParserSettingsImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        if numberOfNodes > 1 {
            return false
        } else {
            return true
        }
    }
    
    var toolTip_importParserSettings: String {
        let nodesCount = selectionManager.selectedNodeIDs.count
        if nodesCount == 0 {
            return "Import Parser"
        } else {
            guard let selectedNode = dataController.selectedNodes.first else {
                return "Import Parser"
            }
            return "Import Parser into \(selectedNode.name)"
        }
    }
    
    
    
    // MARK: - Import Graph Templates
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
    
    
    /// Check if Graph Template files can be imported
    ///
    /// At this time, we don''t import Graph Template files if multiple Nodes are selected.
    func shouldAllGraphTemplatesImport() -> Bool {
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        if numberOfNodes > 1 {
            return false
        } else {
            return true
        }
    }
    
    
    var toolTip_importGraphTemplate: String {
        let nodesCount = selectionManager.selectedNodeIDs.count
        if nodesCount == 0 {
            return "Import Graph Templates"
        } else {
            guard let selectedNode = dataController.selectedNodes.first else {
                return "Import Graph Template"
            }
            return "Import Graph Template into \(selectedNode.name)"
        }
    }
}
