//
//  SourceListViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

@Observable
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
    }
    
    
    func importURLs(_ urls: [URL]) -> Bool {
        
        if shouldAllowDrop(ofURLs: urls) == false {
            self.presentURLImportError = true
            return false
        }
        
        guard let parentNode = selectionManager.selectedNodes.first else {return false}
        
        do {
            try dataController.importURLs(urls, intoNode: parentNode)
            return true
        } catch {
            self.presentURLImportError = true
            return false
        }
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



// MARK: - Drag-and-Drop
extension SourceListViewModel {
    func drop(uuids: [UUID], onto node: Node) {
        
        dataController.tryToMove(uuids: uuids, to: node)
    }
}



// MARK: - Selection and Deselection
extension SourceListViewModel {
    func deselectNodes() {
        selectionManager.deselectNodes()
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
