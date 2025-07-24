//
//  AppControllers.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
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
        var url = try? FileManager.default.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: false)
        
        let fileManager = FileManager.default
        
        url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "edu.HRG.Graphs")
        
        print("Library URL = \(String(describing: url))")
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
        inspectorVM = InspectorViewModel(localDataController, localSelectionManager, localProcessedDataManager)
        dataListVM = DataListViewModel(localDataController, localSelectionManager)
        graphListVM = GraphControllerListViewModel(dataController: localDataController, selectionManager: localSelectionManager, processedDataManager: localProcessedDataManager)
        
        
        // Delegates and DataSources
        localDataController.delegate = self
        localSelectionManager.delegate = self
        localProcessedDataManager.dataSource = self
        
        
        // Set initial node selection to top-level Node
        if let firstNode = localDataController.topNode() {
            let firstNodeSet = Set([firstNode])
            localSelectionManager.selectedNodes = firstNodeSet
        }
    }
}


extension AppController: @preconcurrency DataControllerDelegate {
    // MARK: - Filtering
    func filterDidChange(currentlySelectedDataItemIDs: [DataItem.ID]) {
        selectionManager.filterDidChange(currentlySelectedDataItemIDs: currentlySelectedDataItemIDs)
    }
    
    
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
    func selectedNodeIDsDidChange(_ nodeIDs: Set<Node.ID>) {
        /*
         let sort = SortDescriptor<Node>(\.name)
         dataController.selectedNodes = Array(nodes).sorted(using: sort)
         */
        
        dataController.selectedNodeIDs = Array(nodeIDs)
        
        inspectorVM.nodeInspectorVM.selectedNodeDidChange()
    }
    
    func selectedDataItemsDidChange(_ dataItemsIDs: Set<DataItem.ID>) {
        
        dataController.selectedDataItemIDs = Array(dataItemsIDs)
        graphListVM.updateProcessedData()
        
        let nc = NotificationCenter.default
        nc.post(name: .selectedDataItemDidChange, object: nil, userInfo: nil)
    }
}


extension AppController: @preconcurrency ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.ID] {
        return Array(selectionManager.selectedDataItemIDs)
    }
}
