//
//  SelectionManagerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/15/24.
//

import Foundation
import SwiftData

protocol SelectionManagerDelegate {

    func selectedNodesDidChange(_ nodes: Set<Node>)
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<PersistentIdentifier>)
}

