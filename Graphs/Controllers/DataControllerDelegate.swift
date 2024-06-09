//
//  DataModelDelegate.swift
//  Images-LectureDevelopment
//
//  Created by Owen Hildreth on 4/25/24.
//

import Foundation

protocol DataControllerDelegate {
    func newData(nodes: [Node], andImages dataItems: [DataItem])
    
    // Add
    func preparingToDelete(nodes: [Node])
    
    // ADD
    func preparingToDelete(dataItems: [DataItem])
}
