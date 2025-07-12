//
//  SelectionManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData

// TODO: Add import OrderedCollections
// import OrderedCollections

@Observable
@MainActor
class SelectionManager {
    var delegate: SelectionManagerDelegate?
    
    var selectedNodes: Set<Node> = [] {
        didSet { delegate?.selectedNodesDidChange(selectedNodes) }
    }
    
    
    var selectedDataItemIDs: Set<DataItem.ID> = [] {
        didSet { delegate?.selectedDataItemsDidChange(selectedDataItemIDs) }
    }
    
    var selectedParserSetting: ParserSettings? = nil
    
    var selectedGraphTemplate: GraphTemplate? = nil
}

// MARK: - Handling Filters
extension SelectionManager {
    func filterDidChange(currentlySelectedDataItemIDs: [DataItem.ID]) {
        let currentSelectionManagerDataItemIDs = selectedDataItemIDs
        let incomingSelectedDataItemIDs = Set(currentlySelectedDataItemIDs)
        
        let allowedSelectedDataItemIDs = currentSelectionManagerDataItemIDs.intersection(incomingSelectedDataItemIDs)
        selectedDataItemIDs = allowedSelectedDataItemIDs
    }
}


//MARK: - Handling New Objects
extension SelectionManager {
    
    func newObjects(nodes: [Node], dataItems: [DataItem], graphTemplates: [GraphTemplate], parserSettings: [ParserSettings]) {
        
        // A single new node has been added.  Make that the selection
        if let firstNode = nodes.first {
            if firstNode.name == Node.defaultName {
                selectedNodes = [firstNode]
                return
            }
        }

        
        // Update the new dataItems to be selected
        if !nodes.isEmpty && !dataItems.isEmpty{
            
            let dataItemIDs = dataItems.map( {$0.id} )
            
            let completeSelection = selectedDataItemIDs.union(dataItemIDs)
            
            selectedDataItemIDs = completeSelection
        } else {
            // Only update selection of the selectedNodes
            let completeSelection = selectedNodes.union(nodes)
            
            selectedNodes = completeSelection
        }
        
        
        // Update the Graph Template selection
        if !graphTemplates.isEmpty {
            
            if nodes.isEmpty {
                if let first = graphTemplates.first {
                    self.newGraphTemplate(first)
                }
            } else {
                if let nodeGraph = nodes.first?.getAssociatedGraphTemplate() {
                    newGraphTemplate(nodeGraph)
                }
            }
            
            
        }
        
        // Update the Parser Settings selection
        if !parserSettings.isEmpty {
            
            if nodes.isEmpty {
                if let firstParserSetting = parserSettings.first {
                    self.newParserSetting(firstParserSetting)
                }
            } else {
                if let nodeParser = nodes.first?.getAssociatedParserSettings() {
                    newParserSetting(nodeParser)
                }
            }
        }
    }
    
    func newParserSetting(_ parserSettings: ParserSettings) {
        selectedParserSetting = parserSettings
    }
    
    func newGraphTemplate(_ graphTemplate: GraphTemplate) {
        selectedGraphTemplate = graphTemplate
    }
}


//MARK: -  Handling Deletion
extension SelectionManager {
    
    
    func preparingToDelete(nodes: [Node]) {
        
        if nodes.count == 0 {
            return
        }
    
        // Get all possible nodes that will be deleted due to cascade rule
        var allNodes = Set(nodes)
        
        for nextNode in nodes {
            allNodes.formUnion(nextNode.flattendSubNodes())
        }
        
        
        // Make sure any possible dataItems aren't selected
        var dataItems: Set<DataItem> = []
        
        for nextNode in nodes {
            dataItems.formUnion(nextNode.flattenedDataItems())
        }
        
        // Clear out the selected Data Items
        self.preparingToDelete(dataItems: Array(dataItems))
                
        
        // Next Clear out any deleted Nodes
        if nodes.count > 0 {
            let remainingNodes = selectedNodes.subtracting(allNodes)
            selectedNodes = remainingNodes
            return
        }
    }

    
    func preparingToDelete(dataItems: [DataItem]) {
        // Next Clear out any deleted dataItems
        if dataItems.count > 0 {
            let dataItemsToDelete = dataItems.map( {$0.id} )
            
            let remiainingIds = selectedDataItemIDs.subtracting(dataItemsToDelete)
            selectedDataItemIDs = remiainingIds
            return
        }
    }
    
    
    func preparingToDelete(parserSetting: ParserSettings) {

        if selectedParserSetting?.id == parserSetting.id {
            selectedParserSetting = nil
        }
    }
    
    
    func preparingToDelete(graphTemplate: GraphTemplate) {
        
        if selectedGraphTemplate?.id == graphTemplate.id {
            selectedGraphTemplate = nil
        }
    }
}


// MARK: - Deselection
extension SelectionManager {
    func deselectAll() {
        deselectNodes()
        deselectGraphTemplate()
        deselectParserSettings()
        
    }
    
    func deselectDataItems() {
        selectedDataItemIDs = []
    }
    
    func deselectNodes() {
        deselectDataItems()
        selectedNodes = []
    }
    
    func deselectParserSettings() {
        selectedParserSetting = nil
    }
    
    func deselectGraphTemplate() {
        selectedGraphTemplate = nil
    }
}
