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
class Node {
    // MARK: - Properties
    //var id: UUID
    
    var originalURL: URL?
    
    var name: String
    
    var parent: Node?
    
    @Relationship(deleteRule: .cascade, inverse: \Node.parent)
    var subNodes: [Node]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \DataItem.node)
    var dataItems: [DataItem]
    
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
        
        guard let localSubNodes = self.subNodes else {
            return localItems
        }
        
        for nextSubNode in localSubNodes {
            localItems.append(contentsOf: nextSubNode.flattenedDataItems())
        }
        
        return localItems
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
