//
//  AppControllers.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Observable
class AppController {
    var dataController: DataController
    var selectionManager: SelectionManager
    
    init() {
        let localDataController = DataController(withDelegate: nil)
        
        let localSelectionManager = SelectionManager()
        
        dataController = localDataController
        selectionManager = localSelectionManager
        
        
        localDataController.delegate = self
        localSelectionManager.delegate = self
    }
}


extension AppController: DataControllerDelegate {
    func newData(nodes: [Node], andDataItems dataItems: [DataItem]) {
        // Pass the information down to the Selection Manager because the selectionManager is responsible for knowing how selection state should be udpated
        selectionManager.newData(nodes: nodes, addDataItems: dataItems)    }
    
    func preparingToDelete(nodes: [Node]) {
        selectionManager.preparingToDelete(nodes: nodes)
    }
    
    func preparingToDelete(dataItems: [DataItem]) {
        selectionManager.preparingToDelete(dataItems: dataItems)
    }
}


extension AppController: SelectionManagerDelegate {
    func selectedNodesDidChange(_ nodes: Set<Node>) {
        let sort = SortDescriptor<Node>(\.name)
        dataController.selectedNodes = Array(nodes).sorted(using: sort)
    }
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<PersistentIdentifier>) {
        dataController.selectedDataItemIDs = Array(dataItemsIDs)
    }
    
    
}