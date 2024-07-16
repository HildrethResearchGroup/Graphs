//
//  FolderItem.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Node {
    // MARK: - Properties
    //var id: UUID
    
    var originalURL: URL?
    
    var name: String
    
    var parent: Node?
    
    @Relationship(deleteRule: .cascade, inverse: \Node.parent)
    var subNodes: [Node]? = []
    
    @Relationship(deleteRule: .nullify, inverse: \DataItem.node)
    var dataItems: [DataItem]
    
    var graphTemplate: GraphTemplate?
    
    var parserSettings: ParserSettings?
    
    var nodeTypeStorage: Int
    
    @Transient
    var nodeType: NodeType {
        set {
            nodeTypeStorage = newValue.intForStorage()
        } get {
            NodeType(rawValue: nodeTypeStorage) ?? .child
        }
    }
    
    
    // MARK: - Initializers
    init(url: URL?, parent: Node?) {
        //self.id = UUID()

        self.originalURL = url
        self.parent = parent
        
        self.dataItems = []
        
        if parent == nil {
            nodeTypeStorage = NodeType.root.intForStorage()
        } else {
            nodeTypeStorage = NodeType.child.intForStorage()
        }
        
        // TODO: Implement Subnodes
        self.subNodes = []
        
        self.name = url?.fileName ?? Node.defaultName
    }
    
    
    func flattenedDataItems() -> [DataItem] {
        
        var localItems: [DataItem] = self.dataItems
        
        let allSubNodes = self.flattendSubNodes()
        
        for nextSubNode in allSubNodes {
            localItems.append(contentsOf: nextSubNode.flattenedDataItems())
        }
        
        return localItems
    }
    
    func flattendSubNodes() -> [Node] {
        let localSubNodes: [Node] = self.subNodes ?? []
        
        var output: [Node] = localSubNodes
        
        for nextSubNodes in localSubNodes {
            output.append(contentsOf: nextSubNodes.flattendSubNodes())
        }
        
        return output
    }

}



extension Node {
    static let defaultName = "New Node"
}


// MARK: - Node Types
extension Node {
    enum NodeType: Int {
        case root = 0
        case child = 1
        
        init?(rawValue: Int) {
            if rawValue == 0 {
                self = .root
            } else {
                self = .child
            }
        }
        
        func intForStorage() -> Int {
            switch self {
            case .root: return 0
            case .child: return 1
            }
        }
    }
}
