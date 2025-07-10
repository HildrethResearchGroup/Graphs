//
//  DataController_MovingObjects.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData


extension DataController {
    func tryToMove(uuids: [UUID], to node: Node) {
        
        let nodesToMove = nodes(for: uuids)
        tryToMove(nodes: nodesToMove, to: node)
        
        
        let dataItemstoMove = dataItems(for: uuids)
        tryToMove(dataItems: dataItemstoMove, to: node)
        
        
        self.fetchData()
        
    }
    
    
    private func tryToMove(nodes: [Node], to node: Node) {
        var movableNodes: [Node] = []
        
        for nextNode in nodes {
            if let nextNodeParent = nextNode.parent {
                let isMovable = !nodes.contains(nextNodeParent)
                
                if isMovable {
                    movableNodes.append(nextNode)
                } else {
                    continue
                }
            } else {
                movableNodes.append(nextNode)
            }
        }
        
        for nextMovableNode in movableNodes {
            nextMovableNode.setParent(node)
        }
    }
    
    
    private func tryToMove(dataItems: [DataItem], to node: Node) {
        
        for nextDataItem in dataItems {
            
            // Only move the DataItems that aren't already in the target Node
            let isMovable = nextDataItem.node?.localID != node.localID
            
            if isMovable {
                nextDataItem.node? = node
            }
        }
    }
    
    
    
    // TODO: Update to use a fetch description instead of filtering
    private func nodes(for uuids: [UUID]) -> [Node] {
        let allNodes = allNodes()
        
        if allNodes.count == 0 { return [] }
        
        let filteredNodes = allNodes.filter( { uuids.contains($0.localID)} )
        
        return filteredNodes
    }
    
    
    // TODO: Update to use a fetch description instead of filtering
    private func dataItems(for uuids: [UUID]) -> [DataItem] {
        let allDataItems = allDataItems()
        
        if allDataItems.count == 0 { return [] }
        
        let filteredDataItems = allDataItems.filter( {uuids.contains( $0.localID )} )
        
        return filteredDataItems
    }
}
