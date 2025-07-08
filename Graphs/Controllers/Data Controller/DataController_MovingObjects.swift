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
        
        let nodesToMove = nodesFor(uuids: uuids)
        
        var movableNodes: [Node] = []
        
        for nextNode in nodesToMove {
            if let nextNodeParent = nextNode.parent {
                let isMovable = !nodesToMove.contains(nextNodeParent)
                
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
        
        self.fetchData()
        
    }
    
    
    
    
    private func nodesFor(uuids: [UUID]) -> [Node] {
        let allNodes = allNodes()
        
        if allNodes.count == 0 { return [] }
        
        let filteredNodes = allNodes.filter( { uuids.contains($0.localID)} )
        
        return filteredNodes
    }
}
