//
//  TableData.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/11/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation

struct TableData: Identifiable {
    var id = ID()
    
    var rows: [TableDataRow]
    var columns: [DataColumn]
    
    init(columns: [DataColumn]) {
        self.columns = columns
        self.rows = []
        rows = generateRows(using: columns)
        
    }
    
    private func maxRows(_ columns: [DataColumn]) -> Int {
        let maxColumn = columns.max(by: {$0.data.count > $1.data.count})
        return maxColumn?.data.count ?? 0
    }
    
    private func generateRows(using columns: [DataColumn]) -> [TableDataRow] {
        let maxRows = self.maxRows(columns)
        
        var outputRows: [TableDataRow] = []
        outputRows.reserveCapacity(maxRows)
        
        for rowNumber in 0..<maxRows {
            let newRow = TableDataRow(rowNumber: rowNumber + 1)
            outputRows.append(newRow)
        }
        
        return outputRows
        
    }
    
    
    struct ID: Identifiable, Hashable {
        var id = UUID()
    }
}


// MARK: - Exporting
extension TableData {
    func headerString() -> String? {
        var output: String?
        
        let headerCount = columns.count(where: {!$0.header.isEmpty})
        
        if headerCount != 0 {
            for (index, nextColumn) in columns.enumerated() {
                if index == 0 {
                    output = nextColumn.header
                } else {
                    output?.append("\t\(nextColumn.header)")
                }
            }
        }
        
        return output
    }
    
    func rowString(for id: TableDataRow.ID) -> String {
        let rowNumber = rowNumber(for: id)
        return rowString(for: rowNumber)
    }
    
    
    private func rowNumber(for id: TableDataRow.ID) -> Int? {
        let row = rows.first(where: { $0.id == id })
        return row?.rowNumber
    }
    
    private func rowString(for index: Int?) -> String {
        guard let rowIndex = index else { return "" }
        if columns.isEmpty { return "" }
        
        var output: String = ""
        
        for (columnIndex, nextColumn) in columns.enumerated() {
            let nextDataString = nextColumn.data(for: rowIndex)
            if columnIndex == 0 {
                output.append(nextDataString)
            } else {
                output.append("\t\(nextDataString)")
            }
        }
        return output
    }
    
    
    
}
