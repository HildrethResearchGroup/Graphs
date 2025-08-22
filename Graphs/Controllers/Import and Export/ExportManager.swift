//
//  ExportManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/25/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation

@MainActor
class ExportManager {
    var dataController: DataController
    var processedDataManager: ProcessDataManager
    var selectionManager: SelectionManager
    
    init(_ dataController: DataController, _ processedDataManager: ProcessDataManager, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.processedDataManager = processedDataManager
        self.selectionManager = selectionManager
        
        self.registerForNotifications()
    }
    
    // MARK: - Export Data
    func exportSelectionAsDataGraphFiles() {
        let selectedDataItems = dataController.selectedDataItems
        
        if selectedDataItems.isEmpty { return }
        
        let panel = NSOpenPanel()
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowedContentTypes = [.directory]
        panel.allowsOtherFileTypes = false
        panel.title = "Export Graphs"
        panel.message = "Select Directory to export graphs to."
        
        
        let response = panel.runModal()
        
        guard response == .OK else { return }
        
        guard let targetDirectory = panel.directoryURL else { return }
        
        
        Task {
            let processedData = await processedDataManager.processedData(for: selectedDataItems)
            
            for nextData in processedData {
                guard let nextGraphController = nextData.graphController else { continue }
                
                let fileName = nextData.dataItem.name + ".dgraph"
                
                let targetFileURL = targetDirectory.appending(path: fileName)
                
                try? nextGraphController.dgController?.write(to: targetFileURL)
                
            }
        }
    }
    
    
    var isDisabled_exportGraphsFromSelectedDataItems: Bool {
        return dataController.selectedDataItems.count == 0
    }
    
    
    var toolTip_exportGraphsFromSelectedDataItems: String {
        let dataItems = dataController.selectedDataItems
        let count = dataItems.count
        
        if count == 0 {
            return "No Data selected to Export"
        } else if count == 1 {
            guard let dataItem = dataItems.first else { return "No Data selected to Export" }
            return "Export \(dataItem.name) as DataGraph file"
        } else {
            return "Export \(count) as DataGraph files"
        }
    }
    
    

    // MARK: - Export Parser Settings
    func exportSelectedParserSettings() {
        guard let parserSettings = selectionManager.selectedParserSetting else { return }
        
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.title = "Export Parser Settings"
        panel.allowedContentTypes = [.gparser ?? .data]
        let fileName = parserSettings.name + ".gparser"
        panel.nameFieldStringValue = fileName
        
        let response = panel.runModal()
        
        guard response == .OK else { return }
        
        guard let url = panel.url else { return }
        
        let encoder = JSONEncoder()
        let output = try? encoder.encode(parserSettings.parserSettingsStatic)
        
        try? output?.write(to: url)
    }
    
    
    var isDisabled_exportSelectedParserSettings: Bool {
        return selectionManager.selectedParserSetting == nil
    }
    
    
    var toolTip_exportSelectedParserSettings: String {
        guard let parserSetting = selectionManager.selectedParserSetting else {
            return "No Parser selected"
        }
        return "Export \(parserSetting.name) Parser"
    }
    
}


// MARK: - Notifications
extension ExportManager {
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: .exportSelectionAsDataGraphFiles,
                       object: nil,
                       queue: nil,
                       using: notification_exportSelectionAsDataGraphFiles(_:))
        
        nc.addObserver(forName: .exportParserSettings,
                       object: nil,
                       queue: nil,
                       using: notification_exportParserSettings(_:))
    }
    
    @objc
    private func notification_exportSelectionAsDataGraphFiles(_ notification: Notification) {
        
        exportSelectionAsDataGraphFiles()
    }
    
    
    @objc
    private func notification_exportParserSettings(_ notification: Notification) {
        exportSelectedParserSettings()
    }
}
