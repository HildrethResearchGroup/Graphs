//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
@MainActor
class ProcessDataManager {
    
    private var processedData: [DataItem.ID : ProcessedData] = [:]
    
    var cacheManager: CacheManager
    
    var dataSource: ProcessDataManagerDataSource?
    
    
    // MARK: - Initialization
    init(cacheManager: CacheManager, dataSource: ProcessDataManagerDataSource?) {
        self.cacheManager = cacheManager
        self.dataSource = dataSource
    }
    
    
    func processedData(for dataItems: [DataItem]) async -> [ProcessedData] {
        var output: [ProcessedData] = []
        
        for nextDataItem in dataItems {
            let nextProcessedData = await processedData(for: nextDataItem)
            output.append(nextProcessedData)
        }
        
        return output
    }
    
    func processedData(for dataItem: DataItem) async -> ProcessedData {
        
        let newProcessedData = await ProcessedData(dataItem: dataItem, delegate: self)
        
        processedData[dataItem.id] = newProcessedData
        
        return newProcessedData
        
        /*
         if let output = processedData[dataItem.id] {
             
             return output
             
         } else {
             let newProcessedData = await ProcessedData(dataItem: dataItem, delegate: self)
             
             processedData[dataItem.id] = newProcessedData
             
             return newProcessedData
         }

         */
        
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
        processedData.removeValue(forKey: dataItem.id)
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


extension ProcessDataManager {
    // MARK: - Notifications
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: .parserOnNodeOrDataItemDidChange, object: nil, queue: nil, using: parserOnNodeOrDataItemDidChange(_:))
        
        nc.addObserver(forName: .parserSettingPropertyDidChange, object: nil, queue: nil, using: parserSettingPropertyDidChange(_:))
        
        nc.addObserver(forName: .graphTemplateDidChange, object: nil, queue: nil, using: graphTemplateOnNodeOrDataItemsDidChange(_:))
    }
    
    
    
    private func parserOnNodeOrDataItemDidChange(_ notification: Notification) {
        let info = notification.userInfo
        
        let dataItemIDs: [DataItem.ID] = info?[Notification.UserInfoKey.dataItemIDs] as? [DataItem.ID] ?? []
        
        parserOnDataItemDidChange(forDataItemIDS: dataItemIDs)
    }

    
    private func graphTemplateOnNodeOrDataItemsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let dataItemsKey = Notification.UserInfoKey.dataItemIDs
        
        guard let dataItemIDs: [DataItem.ID] = userInfo[dataItemsKey] as? [DataItem.ID] else { return }
        
        self.graphTemplateChanged(for: dataItemIDs)
    }
    
    
    // MARK: - Implement Graph Template Changes
    private func graphTemplateChanged(for dataItemIDs: [DataItem.ID]) {
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
                        print(error)
                    }
                    
                }
                
            }
        }
        
    }
    
    
    // MARK: - Implement Parser Settings Changes
    private func parserSettingPropertyDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let key = Notification.UserInfoKey.parserSettingsIDs
        
        guard let parserSettingIDs: [UUID] = userInfo[key] as? [UUID] else { return }
        
        guard let parserSettingsID = parserSettingIDs.first else { return }
        
        let processedDataToUpdate: [ProcessedData] = processedData.values.filter( { $0.dataItem.getAssociatedParserSettings()?.localID == parserSettingsID})
        
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
}


protocol ProcessDataManagerDataSource {
    func currentSelection() -> [DataItem.ID]
}
