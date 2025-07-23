//
//  DropItem.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftUI

// https://stackoverflow.com/questions/74290721/how-do-you-mark-a-single-container-as-a-dropdestination-for-multiple-transferabl
enum DropItem: Codable, Transferable {
    case none
    //case uuid(UUID)
    case url(URL)
    case dataItem(DataItem.LocalID)
    case node(Node.LocalID)
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { DropItem.dataItem($0)}
        ProxyRepresentation { DropItem.node($0) }
        ProxyRepresentation { DropItem.url($0) }
    }
    
    
    var dataItem: DataItem.LocalID? {
        switch self {
        case .dataItem(let dataItemID): return dataItemID
        default: return nil
        }
    }
    
    var node: Node.LocalID? {
        switch self {
        case .node(let nodeID): return nodeID
        default: return nil
        }
    }
    
    
    var url: URL? {
        switch self {
            case.url(let url): return url
            default: return nil
        }
    }
}
