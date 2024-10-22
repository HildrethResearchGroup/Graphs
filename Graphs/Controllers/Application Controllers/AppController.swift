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
    
    // Managers
    var selectionManager: SelectionManager
    var cacheManager: CacheManager
    var processedDataManager: ProcessDataManager
    
    
    // View Models
    var sourceListVM: SourceListViewModel
    var inspectorVM: InspectorViewModel
    
    init() {
        // Controllers and Managers
        let localDataController = DataController(withDelegate: nil)
        
        // Managers
        let localSelectionManager = SelectionManager()
        let localCacheManager = CacheManager()
        let localProcessedDataManager = ProcessDataManager(cacheManager: localCacheManager, dataSource: nil)
        
        cacheManager = localCacheManager
        processedDataManager = localProcessedDataManager
        dataController = localDataController
        selectionManager = localSelectionManager
        
        
        
        
        // View Models
        sourceListVM = SourceListViewModel(localDataController, localSelectionManager)
        inspectorVM = InspectorViewModel(localDataController, localSelectionManager)
        
        
        
        // Delegates and DataSources
        localDataController.delegate = self
        localSelectionManager.delegate = self
        localProcessedDataManager.dataSource = self
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
        processedDataManager.preparingToDelete(dataItems: dataItems)
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


extension AppController: ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.ID] {
        return Array(selectionManager.selectedDataItemIDs)
    }
}
