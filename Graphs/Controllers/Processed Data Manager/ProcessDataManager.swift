//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

class ProcessDataManager {
    
    private var activeProcessedData: [DataItem.ID : ProcessedData] = [:]
    
    
    
    func loadData(for dataItem: DataItem) {
        
    }
    
    func processedData(for dataItem: DataItem) async -> ProcessedData {
        if let output = activeProcessedData[dataItem.id] {
            return output
        } else {
            let newProcessedData = await ProcessedData(dataItem: dataItem)
            
            activeProcessedData[dataItem.id] = newProcessedData
            
            return newProcessedData
        }
    }
    
    
    func preparingToDelete(dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            delete(dataItem: nextDataItem)
        }
    }
    
    
    private func delete(dataItem: DataItem) {
        
        guard let processedData = activeProcessedData[dataItem.id] else { return }
        
        processedData.deleteCache()
        
        activeProcessedData.removeValue(forKey: dataItem.id)
    }
}


extension ProcessDataManager {
    // MARK: - Notifications
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: .parserOnDataItemDidChange, object: nil, queue: nil, using: parserOnDataItemDidChange(_:))
        
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
    
    
    private func parserOnDataItemDidChange(forDataItemIDS ids: [DataItem.ID]) {
        
        let processedDataToUpdate = activeProcessedData.filter( {id, data in
            if ids.contains(id) {
                return true
            } else {
                return false
            }
        } )
        
        // TODO: Batch Process
        
        for nextData in processedDataToUpdate.values {
            nextData.parserDidChange()
        }
        
        
    }
    
    private func graphTemplateOnDataItemDidChange() {
        
    }
}
