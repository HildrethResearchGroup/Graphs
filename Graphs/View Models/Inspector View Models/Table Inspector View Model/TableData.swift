//
//  TableData.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/11/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


struct TableDataRow: Identifiable {
    var id = ID()
    
    let rowNumber: Int
    
    struct ID: Identifiable, Hashable {
        var id = UUID()
    }
}

/*
 struct TableDataColumn: Identifiable {
     var id = ID()
     var data: [String]
     
     func data(for rowNumber: Int) -> String {
         if rowNumber < data.count {
             return ""
         } else {
             return data[rowNumber - 1]
         }
     }

     
     struct ID: Identifiable, Hashable {
         var id = UUID()
     }
 }
 */



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
