//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


@MainActor
class ProcessDataManager {
    
    var cachedData: [DataItem.ID : ProcessedData] = [:]
    
    
    
    func loadData(for dataItem: DataItem) {
        
    }
    
    
    func preparingToDelete(dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            delete(dataItem: nextDataItem)
        }
    }
    
    private func delete(dataItem: DataItem) {
        
        guard let processedData = cachedData[dataItem.id] else { return }
        
        processedData.deleteCache()
        
        cachedData.removeValue(forKey: dataItem.id)
    }
}
