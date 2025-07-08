//
//  Inspector_ParserSettings.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/17/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import OSLog


@Observable
@MainActor
class ParserSettingsViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var sort: [KeyPathComparator<ParserSettings>] = [.init(\.name), .init(\.creationDate)]
    
    var selection: ParserSettings? {
        get { selectionManager.selectedParserSetting }
        set { selectionManager.selectedParserSetting = newValue }
    }
    
    var selectedDataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    var parserSettings: [ParserSettings] {
        dataController.parserSettings
    }
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
}


// MARK: - Managing Parser Settings
extension ParserSettingsViewModel {
    func shouldAllowDrop(ofURLs urls: [URL]) -> Bool {
        if urls.count == 0 { return false }
        
        let allowedExtension = URL.parserSettingsFileExtension
        
        for nextURL in urls {
            if nextURL.pathExtension != allowedExtension {
                return false
            }
        }
        
        return true
    }
    
    
    func importURLs(_ urls: [URL]) -> Bool{
        
        let parserExtension = URL.parserSettingsFileExtension
        
        let parserURLs = urls.filter( {$0.pathExtension == parserExtension })
        
        if parserURLs.isEmpty == false { return false }
        
        for nextURL in parserURLs {
            _ = dataController.importParser(from: nextURL, intoNode: nil)
        }
        
        return true
    }
    
    func deleteSelectedParserSetting() {
        if let selectedParserSetting = selection {
            delete(parserSetting: selectedParserSetting)
        }
    }
    
    func delete(parserSetting: ParserSettings) {
        dataController.delete(parserSetting)
    }
    
    func newParserSettings() {
        _ = dataController.createNewParserSetting()
    }
    
    
    func duplicateParserSettings() {
        guard let parserSettings = selection else { return }
        
        _ = dataController.duplicate(parserSettings)
    }
    
    
     func exportParserSettings(to url: URL) {
         guard let parserSettings = selection else { return }
         
         let encoder = JSONEncoder()
         
         let staticSettings = parserSettings.parserSettingsStatic
         
         do {
             let data = try encoder.encode(staticSettings)
             try data.write(to: url)
         } catch  {
             let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Saving")
             logger.error("Could not save Parser Settings \(parserSettings.name) to url: \(url)")
             logger.error("\(error.localizedDescription)")
         }
     }
     
    
}

