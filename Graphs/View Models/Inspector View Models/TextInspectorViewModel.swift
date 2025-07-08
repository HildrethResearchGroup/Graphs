//
//  TextInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/8/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
@MainActor
class TextInspectorViewModel {
    var dataController: DataController
    
    var dataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    var content: String {
        updateStoredContent()
        return storedContent.content
    }
    
    
    private var storedContent: StoredContent = StoredContent(content: "Select File")
    
    
    init(_ dataController: DataController) {
        self.dataController = dataController
    }
    
    
    
    private func getContent() -> String {
        var defaultOutput = ""
        
        guard let dataItem = self.dataItem else { return defaultOutput}
        
        guard let parserSettings = dataItem.getAssociatedParserSettings() else { return defaultOutput}
        
        guard let localContent = try? Parser.content(for: dataItem.url, using: parserSettings.parserSettingsStatic) else { return defaultOutput }
        
        
        return localContent
    }
    
    
    private func updateStoredContent() {
        
        // Set storedContent to nil if the dataItem is also nil
        guard let dataItem = self.dataItem else {
            let localContent = "Select File."
            storedContent = StoredContent(content: localContent)
            return
        }
        
        // File cannot be parsed if there isn't a encoding available
        guard let parserSettings = dataItem.getAssociatedParserSettings() else {
            let localContent = "String Encoding Needed.\nSet Parser for file."
            storedContent = StoredContent(content: localContent)
            return
        }
        
        
        // IDs don't match, need to update the storedContent
        if storedContent.dataItemID != dataItem.id {
            storedContent = StoredContent(dataItem.id, content: getContent())
            return
        }
        
        
        // Check to see if the parserSettings have changed
        let lastModified = parserSettings.lastModified
        
        if lastModified > storedContent.date {
            storedContent = StoredContent(dataItem.id, content: getContent())
            return
        }
        
        // storedContent does not need to be updated
        
        
    }
    
    
    private struct StoredContent {
        let dataItemID: DataItem.ID?
        let content: String
        let date: Date = .now
        
        init(_ dataItemID: DataItem.ID?, content: String) {
            self.dataItemID = dataItemID
            self.content = content

        }
        
        init(content: String) {
            self.dataItemID = nil
            self.content = content
        }
    }
    
}
