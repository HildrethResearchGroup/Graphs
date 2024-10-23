//
//  GraphListViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/22/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import Collections

@Observable
class GraphListViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    private var processedDataManager: ProcessDataManager
    
    var processedData: [ProcessedData] = []
    
    init(dataController: DataController, selectionManager: SelectionManager, processedDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.processedDataManager = processedDataManager
        self.processedData = []
        
        
    }
    
    func updateProcessedData() {
        //let selectedDataItemIDs = selectionManager.selectedDataItemIDs
        let selectedDataItems = Array(dataController.selectedDataItems)
        
        
        Task {
            let localProcessedData = await processedDataManager.processedData(for: selectedDataItems)
            
            await MainActor.run {
                self.processedData = localProcessedData
            }
        }
        
    }
}
