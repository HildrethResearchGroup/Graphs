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
    
    // MARK: - Nodes and Data
    func newData(nodes: [Node], andDataItems dataItems: [DataItem]) {
        // Pass the information down to the Selection Manager because the selectionManager is responsible for knowing how selection state should be udpated
        selectionManager.newData(nodes: nodes, andDataItems: dataItems)    }
    
    func preparingToDelete(nodes: [Node]) {
        selectionManager.preparingToDelete(nodes: nodes)
    }
    
    func preparingToDelete(dataItems: [DataItem]) {
        selectionManager.preparingToDelete(dataItems: dataItems)
    }
    
    
    // MARK: - Graph Template
    func newGraphTemplate(graphTemplate: GraphTemplate) {
        selectionManager.selectedGraphTemplate = graphTemplate
    }
    
    func preparingToDeleteGraphTemplate(graphTemplate: GraphTemplate) {
        selectionManager.preparingToDelete(graphTemplate: graphTemplate)
    }
    
    
    
    // MARK: - Parsersettings
    func newParserSetting(parserSettings: ParserSettings) {
        selectionManager.selectedParserSetting = parserSettings
    }
    
    func preparingToDelete(parserSettings: ParserSettings) {
        selectionManager.preparingToDelete(parserSetting: parserSettings)
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
