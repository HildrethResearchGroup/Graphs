//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import OSLog


@Observable
@MainActor
class ProcessDataManager {
    
    private var processedData: [DataItem.LocalID : ProcessedData] = [:]
    
    var cacheManager: CacheManager
    
    var dataSource: ProcessDataManagerDataSource?
    
    
    // MARK: - Initialization
    init(cacheManager: CacheManager, dataSource: ProcessDataManagerDataSource?) {
        self.cacheManager = cacheManager
        self.dataSource = dataSource
        self.registerForNotifications()
    }
    
    // MARK: - Processed Data
    func processedData(for dataItems: [DataItem]) async -> [ProcessedData] {
        var output: [ProcessedData] = []
        
        for nextDataItem in dataItems {
            let nextProcessedData = await processedData(for: nextDataItem)
            output.append(nextProcessedData)
        }
        
        return output
    }
    
    
    func processedData(for dataItem: DataItem) async -> ProcessedData {
        // Enable Local Caching
         if let output = processedData[dataItem.localID] {
             
             // Check to see if cached data is up to date
             if output.parsedFileState == .upToDate && output.graphTemplateState == .upToDate {
                 // Cached data is up to date, return cached data
                 return output
             } else {
                 // Cached data isn't up to date, reprocess the data
                 return await generateNewProcessedData(for: dataItem)
             }
         } else {
             // No cached data, process data
             return await generateNewProcessedData(for: dataItem)
         }
    }
    
    
    private func generateNewProcessedData(for dataItem: DataItem) async -> ProcessedData {
        let newProcessedData = await ProcessedData(dataItem: dataItem, delegate: self)
        
        processedData[dataItem.localID] = newProcessedData
        
        return newProcessedData
    }
    
    
    
    // MARK: - Deleting
    
    func preparingToDelete(nodes: [Node]) {
        var dataItems: Set<DataItem> = []
        
        for nextNode in nodes {
            dataItems.formUnion(nextNode.flattenedDataItems())
        }
        
        self.preparingToDelete(dataItems: Array(dataItems))
    }
    
    
    func preparingToDelete(dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            delete(dataItem: nextDataItem)
        }
    }
    
    
    private func delete(dataItem: DataItem) {
        processedData.removeValue(forKey: dataItem.localID)
        self.deleteCache(for: dataItem)
    }
    
    
    func preparingToDelete(parserSetting: ParserSettings) {
        
        for nextProcessedData in self.processedData {
            let nextDataItem = nextProcessedData.value.dataItem
            
            if nextDataItem.getAssociatedParserSettings()?.id == parserSetting.id {
                nextProcessedData.value.parsedFileState = .outOfDate
            }
        }
    }
    
    func preparingToDelete(graphTemplate: GraphTemplate) {
        for nextProcessedData in self.processedData {
            let nextDataItem = nextProcessedData.value.dataItem
            
            if nextDataItem.getAssociatedGraphTemplate()?.id == graphTemplate.id {
                nextProcessedData.value.graphTemplateState = .outOfDate
            }
        }
    }
}



// MARK: - Notifications
extension ProcessDataManager {
    
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        
        // TODO: Swift 6 Errors
        //nc.addObserver(forName: .parserOnNodeOrDataItemDidChange, object: nil, queue: nil, using: parserOnNodeOrDataItemDidChange(_:))
        //nc.addObserver(forName: .parserSettingPropertyDidChange, object: nil, queue: nil, using: parserSettingPropertyDidChange(_:))
        //nc.addObserver(forName: .graphTemplateDidChange, object: nil, queue: nil, using: graphTemplateOnNodeOrDataItemsDidChange(_:))
        
        
        nc.addObserver(self, selector: #selector(parserOnNodeOrDataItemDidChange(_:)), name: .parserOnNodeOrDataItemDidChange, object: nil)
        nc.addObserver(self, selector: #selector(parserSettingPropertyDidChange(_:)), name: .parserSettingPropertyDidChange, object: nil)
        nc.addObserver(self, selector: #selector(graphTemplateOnNodeOrDataItemsDidChange(_:)), name: .graphTemplateDidChange, object: nil)
    }
    
    
    
    @objc private func parserOnNodeOrDataItemDidChange(_ notification: Notification) {
        
        let info = notification.userInfo
        
        let dataItemIDs: [DataItem.LocalID] = info?[Notification.UserInfoKey.dataItemIDs] as? [DataItem.LocalID] ?? []
        
        parserOnDataItemDidChange(forDataItemIDS: dataItemIDs)
    }

    
    @objc private func graphTemplateOnNodeOrDataItemsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let dataItemsKey = Notification.UserInfoKey.dataItemIDs
        
        guard let dataItemIDs: [DataItem.LocalID] = userInfo[dataItemsKey] as? [DataItem.LocalID] else {
            print("Error: graphTemplateOnNodeOrDataItemsDidChange")
            return
        }
        
        self.graphTemplateChanged(for: dataItemIDs)
    }
    
    
    // MARK: - Implement Graph Template Changes
    private func graphTemplateChanged(for dataItemIDs: [DataItem.LocalID]) {
        let processedDataToUpdate = processedData.filter({id, data in
            dataItemIDs.contains( where: { $0 == id})
        })
        
        
        // Update parsedFileState to be out of date so that the data is reparsed and regraphed next time the processed data is used
        for nextData in processedDataToUpdate.values {
            nextData.graphTemplateState = .outOfDate
        }
        
        
        // Process only current selection to save resources
        if let currentSelection = dataSource?.currentSelection() {
            let dataItemsToUpdate = processedDataToUpdate.filter( {id, data in
                currentSelection.contains(id) })
            
            for nextProcessedData in dataItemsToUpdate.values {
                Task {
                    do {
                        try await nextProcessedData.loadGraphController()
                    } catch  {
                        Logger.processingData.info("\(error)")
                    }
                }
            }
        }
    }
    
    
    // MARK: - Implement Parser Settings Changes
    @objc private func parserSettingPropertyDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let key = Notification.UserInfoKey.parserSettingsIDs
        
        guard let parserSettingIDs: [ParserSettings.LocalID] = userInfo[key] as? [ParserSettings.LocalID] else { return }
        
        guard let parserSettingsID = parserSettingIDs.first else { return }
        
        let processedDataToUpdate: [ProcessedData] = processedData.values.filter( { $0.dataItem.getAssociatedParserSettings()?.localID == parserSettingsID})
        
        let dataItemIDsToUpdate = processedDataToUpdate.map({ $0.dataItem.localID})
        
        
        parserOnDataItemDidChange(forDataItemIDS: dataItemIDsToUpdate)
    }
    
    
    
    private func parserOnDataItemDidChange(forDataItemIDS ids: [DataItem.LocalID]) {
        
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
}


protocol ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.LocalID]
}
