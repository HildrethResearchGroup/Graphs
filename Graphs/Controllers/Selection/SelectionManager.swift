//
//  SelectionManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

// TODO: Add import OrderedCollections
// import OrderedCollections

@Observable
class SelectionManager {
    @ObservationIgnored var delegate: SelectionManagerDelegate?
    
    var selectedNodes: Set<Node> = [] {
        didSet { delegate?.selectedNodesDidChange(selectedNodes) }
    }
    
    var selectedDataItemIDs: Set<PersistentIdentifier> = [] {
        didSet { delegate?.selectedDataItemsDidChange(selectedDataItemIDs) }
    }
    
    func newData(nodes: [Node], addDataItems dataItems: [DataItem]) {
        
        // A single new node has been added.  Make that the selection
        if let firstNode = nodes.first {
            if firstNode.name == Node.defaultName {
                selectedNodes = [firstNode]
                return
            }
        }

        
        // Only data items have been created.  Update the dataItems
        if !nodes.isEmpty {
            
            let dataItemIDs = dataItems.map( {$0.id} )
            
            if dataItems.isEmpty {
                return
            }
            
            let completeSelection = selectedDataItemIDs.union(dataItemIDs)
            
            selectedDataItemIDs = completeSelection
            return
        } else {
            // Only update selection of the selectedNodes
            let completeSelection = selectedNodes.union(nodes)
            
            selectedNodes = completeSelection
        }
    }
    
    
    func preparingToDelete(nodes: [Node]) {
        // Next Clear out any deleted Nodes
        if nodes.count > 0 {
            let remainingNodes = selectedNodes.subtracting(nodes)
            selectedNodes = remainingNodes
            return
        }
    }

    func preparingToDelete(dataItems: [DataItem]) {
        // Next Clear out any deleted Nodes
        if dataItems.count > 0 {
            let dataItemsToDelete = dataItems.map( {$0.id} )
            
            let remiainingIds = selectedDataItemIDs.subtracting(dataItemsToDelete)
            selectedDataItemIDs = remiainingIds
            return
        }
    }
    
    func deselectAll() {
        selectedDataItemIDs = []
        selectedNodes = []
    }
}
