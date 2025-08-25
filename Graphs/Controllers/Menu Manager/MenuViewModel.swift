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
    
    
    // MARK: - New Folder
    func newFolder() {
        importManager.newNode()
    }
    
    var toolTip_newFolder: String {
        importManager.toolTip_newNode
    }
    
    
    // MARK: - Importing
    func importAll() {
        _ = importManager.importDataFiles()
    }
    
    var isDisabled_importAll: Bool {
        !importManager.shouldAllowAllImport()
    }
    
    var toolTip_importAll: String {
        return importManager.toolTip_importAll
    }
    
    
    func importDataFiles() {
        _ = importManager.importDataFiles()
    }
    
    var isDisabled_importDataFiles: Bool {
        !importManager.shouldAllowDataFileImport()
    }
    
    var toolTip_importDataFiles: String {
        importManager.toolTip_importDataFiles
    }
    
    

    func importGraphTemplate() {
        _ = importManager.importGraphTemplate()
    }
    
    var isDisabled_importGraphTemplate: Bool {
        !importManager.shouldAllGraphTemplatesImport()
    }
    
    var toolTip_importGraphTemplate: String {
        importManager.toolTip_importGraphTemplate
    }
    
    

    func importParserSettings() {
        _ = importManager.importParserSettings()
    }
    
    
    var isDisabled_importParserSettings: Bool {
        !importManager.shouldAllGraphTemplatesImport()
    }
    
    var toolTip_importParserSettings: String {
        importManager.toolTip_importParserSettings
    }
    
    
    
    // MARK: - Exporting
    func exportGraphsFromSelectedDataItems() {
        exportManager.exportSelectionAsDataGraphFiles()
    }
    
    var isDisabled_exportGraphsFromSelectedDataItems: Bool {
        exportManager.isDisabled_exportGraphsFromSelectedDataItems
    }
    
    
    var toolTip_exportGraphsFromSelectedDataItems: String {
        exportManager.toolTip_exportGraphsFromSelectedDataItems
    }
    
    
    
    
    func exportSelectedParserSettings() {
        exportManager.exportSelectedParserSettings()
    }
    
    var isDisabled_exportSelectedParserSettings: Bool {
        return exportManager.isDisabled_exportSelectedParserSettings
    }
    
    var toolTip_exportSelectedParserSettings: String {
        return exportManager.toolTip_exportSelectedParserSettings
    }
    
    
    
    
    // MARK: - Deletion
    func deleteSelectedDataItems() {
        let dataItemsToDelete = dataController.selectedDataItems
        
        if dataItemsToDelete.isEmpty { return }
        
        dataController.delete(dataItemsToDelete, andThenNodes: [])
    }
    
    var isDisabled_deleteSelectedDataItem: Bool {
        return selectionManager.selectedDataItemIDs.isEmpty
    }
    
    var toolTip_deleteSelectedDataItem: String {
        let dataItemsToDelete = dataController.selectedDataItems
        let count = dataItemsToDelete.count
        
        if count == 0 {
            return "No data selected"
        } else if count == 1 {
            guard let dataItem = dataItemsToDelete.first else {
                return "Remove Data"
            }
            
            return "Remove \(dataItem.name) File"
        } else {
            return "Remove \(count) Files"
        }
    }
    
    
    
    func deleteSelectedNodes() {
        let nodesToDelete = dataController.selectedNodes
        
        if nodesToDelete.isEmpty { return }
        
        dataController.delete([], andThenNodes: nodesToDelete)
    }
    
    var isDisabled_deleteSelectedNodes: Bool {
        return selectionManager.selectedDataItemIDs.isEmpty
    }
    
    var toolTip_deleteSelectedNodes: String {
        let toDelete = dataController.selectedNodes
        let count = toDelete.count
        
        if count == 0 {
            return "No Folders selected"
        } else if count == 1 {
            guard let node = toDelete.first else {
                return "Remove Folder"
            }
            
            return "Remove \(node.name) Folder"
        } else {
            return "Remove \(count) Folders"
        }
    }
    
    
    
    
    func deleteSelectedGraphTemplate() {
        guard let graphTemplateToDelete = selectionManager.selectedGraphTemplate else { return }
        
        dataController.delete(graphTemplateToDelete)
    }
    
    var isDisabled_deleteSelectedGraphTemplate: Bool {
        return selectionManager.selectedGraphTemplate == nil
    }
    
    var toolTip_deleteSelectedGraphTemplate: String {
        guard let graphTemplate = selectionManager.selectedGraphTemplate else {
            return "No Graph Templates selected"
        }
        
        return "Remove \(graphTemplate.name) Graph Template"
    }
    
    
    
    
    func deleteSelectedParserSettings() {
        guard let parseSettingsToDelete = selectionManager.selectedParserSetting else { return }
        
        dataController.delete(parseSettingsToDelete)
    }
    
    var isDisabled_deleteSelectedParserSettings: Bool {
        return selectionManager.selectedParserSetting == nil
    }
    
    var toolTip_deleteSelectedParserSettings: String {
        guard let parserSetting = selectionManager.selectedParserSetting else {
            return "No Parser selected"
        }
        
        return "Remove \(parserSetting.name) Parser"
    }
    
    
    
    
    
    // MARK: - Selection
    func clearSelection() {
        selectionManager.deselectAll()
    }
    
}

// MARK: - Button State
extension MenuViewModel {
    
    
    var isDisabledd_clearSelection: Bool {
        return false
    }
    
}
