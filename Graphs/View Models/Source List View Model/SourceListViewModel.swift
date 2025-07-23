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
    
    
    var selection: Set<Node> {
        get { selectionManager.selectedNodes }
        set { selectionManager.selectedNodes = newValue }
    }
    
    var rootNodes: [Node] {
        dataController.rootNodes
    }
    
    var presentURLImportError = false
    
    var sort: [KeyPathComparator<DataItem>] = [.init(\.name), .init(\.nodeName)]
    
    // MARK: - Initialization
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
}


extension SourceListViewModel {
    
    func shouldAllowDrop(ofURLs urls: [URL]) -> Bool {
        if urls.count == 0 { return false }
        
        let numberOfNodes = selectionManager.selectedNodes.count
        
        switch numberOfNodes {
        case 0: return false
        case 1: return true
        default: return false
        }
    }
    
    func importURLs(_ urls: [URL], intoNode parentNode: Node?) -> Bool {
        
        let success = dataController.importURLs(urls, intoNode: parentNode)
        
        return success
        
        /*
         do {
             try dataController.importURLs(urls, intoNode: parentNode)
             
             return true
         } catch {
             if let importError = error as? DataController.ImportError {
                 if importError == .cannotImportFileWithoutANode {
                     self.presentURLImportError = true
                     return false
                 }
             }
             return false
         }
         */
        
    }
    
    
    func importURLs(_ urls: [URL]) -> Bool {
        
        if shouldAllowDrop(ofURLs: urls) == false {
            self.presentURLImportError = true
            return false
        }
        
        guard let parentNode = selectionManager.selectedNodes.first else {return false}
        
        let success = dataController.importURLs(urls, intoNode: parentNode)
        
        if success == false {
            self.presentURLImportError = true
        }
        
        return success
        
        /*
         do {
             try dataController.importURLs(urls, intoNode: parentNode)
             return true
         } catch {
             self.presentURLImportError = true
             return false
         }
         */
        
        
    }
}


// MARK: - Deleting and Adding Nodes
extension SourceListViewModel {
    func deleteSelectedNodes() {
        let nodes = Array(selection)
        dataController.delete(nodes)
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
        
        switch selectionManager.selectedNodes.count {
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
