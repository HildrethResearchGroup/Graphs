//
//  SelectionManagerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/15/24.
//

import Foundation
import SwiftData

protocol SelectionManagerDelegate {

    func selectedNodeIDsDidChange(_ nodeIDs: Set<Node.ID>)
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<DataItem.ID>)
}

