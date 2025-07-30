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
    var exportManager: ExportManager
    var importManager: ImportManager
    var processedDataManager: ProcessDataManager
    var menuManager: MenuViewModel
    
    
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
        let localImportManager = ImportManager(localDataController, localSelectionManager)
        let localExportManager = ExportManager(localDataController, localProcessedDataManager, localSelectionManager)
        
        
        // Use a Common Manager to simplify the API for view models
        let commonManagers = CommonManagers(localDataController, localSelectionManager, localProcessedDataManager, localExportManager, localImportManager)
        
        let localMenuManager = MenuViewModel(commonManagers)
        
        
        
        // Set properties
        cacheManager = localCacheManager
        dataController = localDataController
        exportManager = localExportManager
        importManager = localImportManager
        processedDataManager = localProcessedDataManager
        selectionManager = localSelectionManager
        menuManager = localMenuManager
        
        
        
        // View Models
        dataListVM = DataListViewModel(commonManagers)
        graphListVM = GraphControllerListViewModel(commonManagers)
        inspectorVM = InspectorViewModel(commonManagers)
        sourceListVM = SourceListViewModel(commonManagers)
        
        
        // Delegates and DataSources
        localDataController.delegate = self
        localSelectionManager.delegate = self
        localProcessedDataManager.dataSource = self
        
        
        // Set initial node selection to top-level Node
        if let firstNode = localDataController.topNode() {
            let firstNodeIDs = Set([firstNode.id])
            localSelectionManager.selectedNodeIDs = firstNodeIDs
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


extension AppController {
    class CommonManagers {
        var dataController: DataController
        var selectionManager: SelectionManager
        var processedDataManager: ProcessDataManager
        
        var exportManager: ExportManager
        var importManager: ImportManager
        
        init(_ dataController: DataController,
             _ selectionManager: SelectionManager,
             _ processedDataManager: ProcessDataManager,
             _ exportManager: ExportManager,
             _ importManager: ImportManager) {
            
            self.dataController = dataController
            self.selectionManager = selectionManager
            self.processedDataManager = processedDataManager
            self.exportManager = exportManager
            self.importManager = importManager
        }
    }
}
