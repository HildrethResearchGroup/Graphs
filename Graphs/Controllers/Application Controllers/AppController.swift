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
@MainActor
class AppController {
    var dataController: DataController
    
    // Managers
    var selectionManager: SelectionManager
    var cacheManager: CacheManager
    var processedDataManager: ProcessDataManager
    
    
    // View Models
    var sourceListVM: SourceListViewModel
    var inspectorVM: InspectorViewModel
    var dataListVM: DataListViewModel
    var graphListVM: GraphControllerListViewModel
    
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
        dataListVM = DataListViewModel(localDataController, localSelectionManager)
        graphListVM = GraphControllerListViewModel(dataController: localDataController, selectionManager: localSelectionManager, processedDataManager: localProcessedDataManager)
        
        
        // Delegates and DataSources
        localDataController.delegate = self
        localSelectionManager.delegate = self
        localProcessedDataManager.dataSource = self
    }
}


extension AppController: @preconcurrency DataControllerDelegate {
    
    // MARK: - Nodes and Data
    func newObjects(nodes: [Node], dataItems: [DataItem], graphTemplates: [GraphTemplate], parserSettings: [ParserSettings]) {
        // Pass the information down to the Selection Manager because the selectionManager is responsible for knowing how selection state should be udpated
        selectionManager.newObjects(nodes: nodes, dataItems: dataItems, graphTemplates: graphTemplates, parserSettings: parserSettings)
        
        
    }
    
    func preparingToDelete(nodes: [Node]) {
        selectionManager.preparingToDelete(nodes: nodes)
        processedDataManager.preparingToDelete(nodes: nodes)
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


extension AppController: @preconcurrency SelectionManagerDelegate {
    func selectedNodesDidChange(_ nodes: Set<Node>) {
        let sort = SortDescriptor<Node>(\.name)
        dataController.selectedNodes = Array(nodes).sorted(using: sort)
        inspectorVM.nodeInspectorVM.selectedNodeDidChange()
    }
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<DataItem.ID>) {
        dataController.selectedDataItemIDs = Array(dataItemsIDs)
        graphListVM.updateProcessedData()
    }
}


extension AppController: @preconcurrency ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.ID] {
        return Array(selectionManager.selectedDataItemIDs)
    }
}
