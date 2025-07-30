//
//  SourceListViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import OrderedCollections

@Observable
@MainActor
class SourceListViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    private var importManager: ImportManager
    
    
    var selection: Set<Node.ID> {
        get { selectionManager.selectedNodeIDs }
        set { selectionManager.selectedNodeIDs = newValue }
    }
    
    var rootNodes: [Node] {
        dataController.rootNodes
    }
    
    var presentURLImportError = false
    
    var sort: [KeyPathComparator<DataItem>] = [.init(\.name), .init(\.nodeName)]
    
    // MARK: - Initialization
    private init(_ dataController: DataController, _ selectionManager: SelectionManager, _ importManager: ImportManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.importManager = importManager
    }
    
    
    convenience init(_ commonManagers: AppController.CommonManagers) {
        let cm = commonManagers
        self.init(cm.dataController, cm.selectionManager, cm.importManager)
    }
}


extension SourceListViewModel {
    
    /// Imports Data Files
    ///
    /// Uses ImportManager to present and open panel and process the results.
    func importDataFiles() {
        _ = importManager.importDataFiles()
    }
    
    /// Imports Parser Settings Files
    ///
    /// Uses ImportManager to present and open panel and process the results.
    func importParserSettings() {
        _ = importManager.importParserSettings()
    }
    
    
    /// Imports Graph Template Files
    ///
    /// Uses ImportManager to present and open panel and process the results.
    func importGraphTemplate() {
        _ = importManager.importGraphTemplate()
    }
    
    
    
    func shouldAllowDrop(ofURLs urls: [URL]) -> Bool {
        if urls.count == 0 { return false }
        
        let numberOfNodes = selectionManager.selectedNodeIDs.count
        
        switch numberOfNodes {
        case 0: return false
        case 1: return true
        default: return false
        }
    }
    
    func importURLs(_ urls: [URL], intoNode parentNode: Node?) -> Bool {
        let success = dataController.importURLs(urls, intoNode: parentNode)
        
        return success
    }
    
    
    func importDirectories() {

        
    }
    
    func importURLs(_ urls: [URL]) -> Bool {
        if shouldAllowDrop(ofURLs: urls) == false {
            self.presentURLImportError = true
            return false
        }
        
        let success = importManager.importDataFiles()
        
        if success == false {
            self.presentURLImportError = true
        }
        
        return success
    }
}


// MARK: - Deleting and Adding Nodes
extension SourceListViewModel {
    func deleteSelectedNodes() {
        let nodeIDs = Array(selection)
        dataController.delete(nodeIDs)
    }
    
    func createEmptyNode(withParent parent: Node?) {
        dataController.createEmptyNode(withParent: parent)
    }
}


// MARK: - Deleting DataItems
extension SourceListViewModel {
    func deleteSelectedDataItems() {
        let dataItems = Array(dataController.selectedDataItems)
        dataController.delete(dataItems, andThenNodes: [])
    }
}


// MARK: - Drag-and-Drop
extension SourceListViewModel {
    
    func drop(items: [DropItem], onto node: Node) {
        
        var urls: [URL] = [URL]()
        var dataItemIDs: [DataItem.LocalID] = [DataItem.LocalID]()
        var nodeIDs: [Node.LocalID] = [Node.LocalID]()
        
        
        for nextItem in items {
            switch nextItem {
            case .dataItem(let dataItemID): dataItemIDs.append(dataItemID)
            case .node(let nodeID): nodeIDs.append(nodeID)
            case .url (let url): urls.append(url)
            case .none: continue
            }
        }
        
        
        if !dataItemIDs.isEmpty || !nodeIDs.isEmpty {
            dataController.move(dataItemIDs: dataItemIDs, and: nodeIDs, to: node)
        }

        
        if urls.count != 0 {
            _ = importURLs(urls, intoNode: node)
        }
    }
}



// MARK: - Selection and Deselection
extension SourceListViewModel {
    func deselectNodes() {
        selectionManager.deselectNodes()
    }
    
    func deselectedDataItems() {
        selectionManager.deselectDataItems()
    }
}



// MARK: - ButtonDisabled
extension SourceListViewModel {
    var disabledButton_importFile: Bool {
        
        switch selectionManager.selectedNodeIDs.count {
        case 0: return true
        case 1: return false
        default: return true
        }
        
    }
}


// MARK: - Tool Tips
extension SourceListViewModel {
    var toolTip_importFile: String {
        "Import Data Files into selected Folder.  Note, only one Folder can be selected to import Data Files"
    }
}
