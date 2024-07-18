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
    
    // View Models
    var sourceListVM: SourceListViewModel
    var inspectorVM: InspectorViewModel
    
    init() {
        // Controllers and Managers
        let localDataController = DataController(withDelegate: nil)
        
        let localSelectionManager = SelectionManager()
        
        dataController = localDataController
        selectionManager = localSelectionManager
        
        
        // View Models
        sourceListVM = SourceListViewModel(localDataController, localSelectionManager)
        inspectorVM = InspectorViewModel(localDataController, localSelectionManager)
        
        
        // Delegates and DataSources
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
    func newGraphTemplate(_ graphTemplate: GraphTemplate) {
        selectionManager.selectedGraphTemplate = graphTemplate
    }
    
    func preparingToDelete(graphTemplate: GraphTemplate) {
        selectionManager.preparingToDelete(graphTemplate: graphTemplate)
    }
    
    
    
    // MARK: - Parsersettings
    func newParserSetting(_ parserSettings: ParserSettings) {
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
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<DataItem.ID>) {
        dataController.selectedDataItemIDs = Array(dataItemsIDs)
    }
    
    
}
