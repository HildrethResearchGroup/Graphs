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
    
    var dataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    var tableColumns: [TableDataColumn] = []
    
    private var processedData: ProcessedData?
    
    private var dataColumns: [DataColumn] {
        guard let data = processedData?.parsedFile?.data else {
            let emptyColumn = DataColumn(headers: ["File Not Parsed"], emptyRows: 5)
            return [emptyColumn]
        }
        
        return data
    }
    
    
    
    
    
    // MARK: View State
    var viewIsVisable: Bool = false {
        didSet {
            updateProcessedData()
        }
    }
    
    private var processingState: ProcessingState = .none
    
    
    init(_ dataController: DataController, _ processDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.processDataManager = processDataManager
    }
    
    
    private func updateDataTableColumns() {
        let localDataColumns = dataColumns
        
        let capacitySize = localDataColumns.count
        var localTableColumns: [TableDataColumn] = []
        localTableColumns.reserveCapacity(capacitySize)
        
        for nextDataColumn in dataColumns {
            let nextTableColumn = TableDataColumn(nextDataColumn)
            localTableColumns.append(nextTableColumn)
        }
        
        tableColumns = localTableColumns
    }
    
    private func updateProcessedData() {
        if viewIsVisable == false { return }
        
        if processingState == .inProgress { return }
        
        guard let dataItem else {
            processingState = .none
            tableColumns = []
            return
        }
        
        guard let processedData else {
            Task {
                processingState = .inProgress
                let localProcessedData = await processDataManager.processedData(for: dataItem)
                self.processedData = localProcessedData
                
                updateDataTableColumns()
                processingState = .upToDate
            }
            
            return
        }
        
        
        if processedData.parsedFileState != .upToDate {
            Task {
                processingState = .inProgress
                let localProcessedData = await processDataManager.processedData(for: dataItem)
                self.processedData = localProcessedData
                updateDataTableColumns()
                processingState = .upToDate
            }
            
            return
        }
        
    }
    
    
    struct DataPoint: Identifiable, Hashable {
        var id = UUID()
        var data: String
    }
    
    struct TableRow: Identifiable {
        var id = UUID()
        
        var data: [String]
    }
    
    
    struct TableDataColumn: Identifiable {
        var id = UUID()
        var header: String
        var data: [DataPoint]
        
        init(_ columnIn: DataColumn) {
            self.header = columnIn.header
            
            let allocateSize = columnIn.data.count
            var localData: [DataPoint] = []
            localData.reserveCapacity(allocateSize)
            
            
            for nextData in columnIn.data {
                let newDataPoint = DataPoint(data: nextData)
                localData.append(newDataPoint)
            }
            
            self.data = localData
        }
    }
    
}
