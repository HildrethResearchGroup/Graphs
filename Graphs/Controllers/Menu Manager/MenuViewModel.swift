//
//  MenuManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/25/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import AppKit

@Observable
@MainActor
class MenuViewModel {
    
    private var dataController: DataController
    private var selectionManager: SelectionManager
    private var exportManager: ExportManager
    private var importManager: ImportManager

    
    private init(_ dataController: DataController, _ selectionManager: SelectionManager, _ exportManager: ExportManager, _ importManager: ImportManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.exportManager = exportManager
        self.importManager = importManager
    }
    
    convenience init(_ commonManagers: AppController.CommonManagers) {
        let cm = commonManagers
        self.init(cm.dataController, cm.selectionManager, cm.exportManager, cm.importManager)
    }
    
    
    // MARK: - Importing
    func newFolder() {
        importManager.newNode()
    }
    
    func importFiles() {
        _ = importManager.importDataFiles()
    }
    
    
    
    func importFolder() {
        
    }
    
    
    func importGraphTemplate() {
        
    }
    
    
    
    func importParserSettings() {
        
    }
    
    
    
    // MARK: - Deletion
    func deleteSelectedDataItems() {
        let dataItemsToDelete = dataController.selectedDataItems
        
        if dataItemsToDelete.isEmpty { return }
        
        dataController.delete(dataItemsToDelete, andThenNodes: [])
    }
    
    func deleteSelectedNodes() {
        let nodesToDelete = dataController.selectedNodes
        
        if nodesToDelete.isEmpty { return }
        
        dataController.delete([], andThenNodes: nodesToDelete)
    }
    
    
    func deleteSelectedGraphTemplate() {
        guard let graphTemplateToDelete = selectionManager.selectedGraphTemplate else { return }
        
        dataController.delete(graphTemplateToDelete)
    }
    
    func deleteSelectedParserSettings() {
        guard let parseSettingsToDelete = selectionManager.selectedParserSetting else { return }
        
        dataController.delete(parseSettingsToDelete)
    }
    
    
    // MARK: - Selection
    func clearSelection() {
        selectionManager.deselectAll()
    }
    
    
    // MARK: - Export
    func exportGraphsFromSelectedDataItems() {
        exportManager.exportSelectionAsDataGraphFiles()
    }
    
    func exportSelectedParserSettings() {
        exportManager.exportSelectedParserSettings()
    }
    
}

// MARK: - Button State
extension MenuViewModel {
    
    var isEnabled_importFiles: Bool {
        return false
    }
    
    
    var isEndabled_importGraphTemplate: Bool {
        return false
    }
    
    var isEnabled_deleteSelectedDataItem: Bool {
        return false
    }
    
    var isEnabled_deleteSelectedNodes: Bool {
        return false
    }
    
    var isEnabled_deleteSelectedGraphTemplate: Bool {
        return false
    }
    
    var isEnabled_deleteSelectedParserSettings: Bool {
        return false
    }
    
    var isEnabled_clearSelection: Bool {
        return false
    }
    
    var isEnabled_exportGraphsFromSelectedDataItems: Bool {
        return false
    }
}
