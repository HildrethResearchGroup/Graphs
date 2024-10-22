//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
class ProcessDataManager {
    
    private var processedData: [DataItem.ID : ProcessedData] = [:]
    
    var cacheManager: CacheManager
    
    var dataSource: ProcessDataManagerDataSource?
    
    
    // MARK: - Initialization
    init(cacheManager: CacheManager, dataSource: ProcessDataManagerDataSource?) {
        self.cacheManager = cacheManager
        self.dataSource = dataSource
    }
    
    
    func loadData(for dataItem: DataItem) {
        
    }
    
    func processedData(for dataItem: DataItem) async -> ProcessedData {
        if let output = processedData[dataItem.id] {
            return output
        } else {
            let newProcessedData = await ProcessedData(dataItem: dataItem, delegate: self)
            
            processedData[dataItem.id] = newProcessedData
            
            return newProcessedData
        }
    }
    
    
    func preparingToDelete(dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            delete(dataItem: nextDataItem)
        }
    }
    
    
    private func delete(dataItem: DataItem) {
        self.deleteCache(for: dataItem)
        
        processedData.removeValue(forKey: dataItem.id)
    }
}


extension ProcessDataManager {
    // MARK: - Notifications
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: .parserOnDataItemDidChange, object: nil, queue: nil, using: parserOnDataItemDidChange(_:))
        
        nc.addObserver(forName: .parserSettingPropertyDidChange, object: nil, queue: nil, using: parserSettingPropertyDidChange(_:))
        
        nc.addObserver(forName: .graphTemplateOnDataItemDidChange, object: nil, queue: nil, using: graphTemplateOnDataItemDidChange(_:))
    }
    
    
    
    private func parserOnDataItemDidChange(_ notification: Notification) {
        let info = notification.userInfo
        
        let dataItemIDs: [DataItem.ID] = info?["dataItem.ids"] as? [DataItem.ID] ?? []
        
        parserOnDataItemDidChange(forDataItemIDS: dataItemIDs)
    }

    
    private func graphTemplateOnDataItemDidChange(_ notification: Notification) {
        self.graphTemplateOnDataItemDidChange()
    }
    
    
    private func parserSettingPropertyDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let key = Notification.Name.parserSettingPropertyDidChange.rawValue
        
        guard let parserSettingID: UUID = userInfo[key] as? UUID else { return }
        
        let processedDataToUpdate: [ProcessedData] = processedData.values.filter( { $0.dataItem.getAssociatedParserSettings()?.localID == parserSettingID})
        
        let dataItemIDsToUpdate = processedDataToUpdate.map({ $0.dataItem.id})
        
        
        parserOnDataItemDidChange(forDataItemIDS: dataItemIDsToUpdate)
    }
    
    
    
    
    private func parserOnDataItemDidChange(forDataItemIDS ids: [DataItem.ID]) {
        
        let processedDataToUpdate = processedData.filter( {id, data in
            if ids.contains(id) {
                return true
            } else {
                return false
            }
        } )
        
        // Update parsedFileState to be out of date so that the data is reparsed and regraphed next time the processed data is used
        for nextData in processedDataToUpdate.values {
            nextData.parsedFileState = .outOfDate
        }
        
        
        // Process only current selection to save resources
        if let currentSelection = dataSource?.currentSelection() {
            let dataItemsToUpdate = processedDataToUpdate.filter( {id, data in
                currentSelection.contains(id)
            })
            
            // Directly update the ProcessedData for the current selection
            Task {
                for nextData in dataItemsToUpdate.values {
                    nextData.parserDidChange()
                }
            }// END: Task
        }// END: Current Selection update
    
    }
    
    private func graphTemplateOnDataItemDidChange() {
        
    }
}


protocol ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.ID]
}
