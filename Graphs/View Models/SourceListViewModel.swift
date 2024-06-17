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
    init(dataController: DataController, selectionManager: SelectionManager) {
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
