//
//  TableInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/10/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
@MainActor
class TableInspectorViewModel {
    var dataController: DataController
    var processDataManager: ProcessDataManager
    
    fileprivate var dataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    private var processedData: ProcessedData? {
        didSet {
            updateTableData()
        }
    }
    
    var tableData: TableData
    
    
    
    // MARK: View State
    var viewIsVisable: Bool = false {
        didSet {
            
            updateProcessedData()
        }
    }
    
    
    private var processingState: ProcessingState = .none
    
    
    // MARK: - Initialization
    init(_ dataController: DataController, _ processDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.processDataManager = processDataManager
        self.tableData = TableData(columns: [])
        registerForNotifications()
    }
    
    
    // MARK: - Updating State
    private func updateTableData() {
        
        if dataItem == nil {
            processingState = .none
            return
        }
        

        
        guard let processedData else {
            processingState = .none
            return
        }
        
        
        guard let parsedFile = processedData.parsedFile else {
            processingState = .none
            return
        }
        
        processingState = .inProgress
        
        let newTableData = TableData(columns: parsedFile.data)
        
        tableData = newTableData
    }
    
    
    private func updateProcessedData() {
        
        if viewIsVisable == false { return }
        
        if processingState == .inProgress { return }
        
        guard let dataItem else {
            processingState = .none
            processedData = nil
            return
        }
        
        Task {
            processingState = .inProgress
            let localProcessedData = await processDataManager.processedData(for: dataItem)
            
            self.processedData = localProcessedData
        }
    }
}


// MARK: - UI
extension TableInspectorViewModel {
    var dataItemName: String {
        dataItem?.name ?? "Select Data"
    }
}



// MARK: - Notifications
extension TableInspectorViewModel {
    fileprivate func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
                       selector: #selector(selectedDataItemDidChange(_:)),
                       name: .selectedDataItemDidChange,
                       object: nil)
    }
    
    @objc func selectedDataItemDidChange(_ notification: Notification) {
        self.processingState = .outOfDate
        
        self.updateProcessedData()
    }
}
