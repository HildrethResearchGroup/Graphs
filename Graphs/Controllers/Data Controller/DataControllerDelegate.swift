//
//  DataControllerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/25/24.
//

import Foundation

protocol DataControllerDelegate {
    func newData(nodes: [Node], andDataItems dataItems: [DataItem])
    
    // Add
    func preparingToDelete(nodes: [Node])
    
    // ADD
    func preparingToDelete(dataItems: [DataItem])
}
