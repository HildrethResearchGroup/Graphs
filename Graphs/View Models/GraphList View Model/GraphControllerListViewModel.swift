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
@MainActor
class GraphControllerListViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    private var processedDataManager: ProcessDataManager
    
    var processedData: [ProcessedData] = [] {
        didSet {
            print("Updated Processed Data with \(processedData.count) items")
        }
    }
    
    init(dataController: DataController, selectionManager: SelectionManager, processedDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.processedDataManager = processedDataManager
        self.processedData = []
        
        self.updateProcessedData()
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
