//
//  ParsedFile.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import TabularData

/// The parsed contents of a file.
struct ParsedFile: Sendable, Codable {
    
    var lastParsedDate: Date = .now
    
    var dataItemID: UUID
    
    /// A string made from the lines spanning the Data's Experimental Details or an empty string if the parser does not include any Experimental Details
    ///
    /// - Note: This section may contain newline characters.  This data is cached.
    var experimentDetails: String = ""
    
    
    /// An array of header rows. Each row is made by seperating the input file by the header separator character set.
    ///
    /// - NOTE: This data is NOT cached.
    var header: [[String]] = [[String]]() {
        didSet {
            updateCollapseHeaders()
        }
    }
    
    private var collapsedHeaders: [String] = []
    
    
    
    /// An array of data rows. Each row is made by seperating the input file by the data separator character set.
    ///
    /// - NOTE: This data is NOT cached.
    //var data: [[String]]
    
    var data: [DataColumn] = []
    
    
    
    /// A string made from the lines spanning the input file's footer, or an empty string if the Data does not include a Footer.
    ///
    /// - Note: This section may contain newline characters.
    var footer: String = ""
    
    
    
    init(dataItemID: UUID) {
        self.dataItemID = dataItemID
    }
    
    mutating func appendRow(_ row: [String]) {
        appendRow(row, withHeaders: collapsedHeaders)
        lastParsedDate = .now
    }
    
    
    private mutating func updateCollapseHeaders() {
        
        let largestColumn = header.max(by: {$0.count > $1.count})
        let maxNumberOfColumns = largestColumn?.count ?? 0
        
        if maxNumberOfColumns == 0 {
            collapsedHeaders = [""]
            return
        }
        
        var localHeaders: [String] = []
        
        for _ in 1...maxNumberOfColumns {
            localHeaders.append("")
        }
        
        
        
        for (rowIndex, nextHeaderRow) in header.enumerated() {
            for (columnIndex, headerString) in nextHeaderRow.enumerated() {
                if rowIndex == 0 {
                    localHeaders[columnIndex] = headerString
                } else {
                    let currentHeader = localHeaders[columnIndex]
                    localHeaders[columnIndex] = currentHeader + "\n" + headerString
                }
            }
        }
        
        collapsedHeaders = localHeaders
    }
    
    
    private mutating func appendRow(_ row: [String], withHeaders headers: [String]) {
        
        let rowCompatibility = RowCompatibility(rowCount: row.count, dataCount: data.count)
        
        switch rowCompatibility {
        case .dataIsEmpty: createInitialDataColumns(withRow: row, andHeaders: collapsedHeaders)
        case .equalCount:
            appendEqualRow(row)
        case let .lessColumnsThanData(numberOfNeededColumns):
            for _ in 0..<numberOfNeededColumns {
                let numberOfNeededRows = data.first?.data.count ?? 0
                
                let emptyColumn = DataColumn(headers: headers, emptyRows: numberOfNeededRows)
                data.append(emptyColumn)
                
            }
            appendEqualRow(row)
        case let .moreColumnsThanData(numberOfNeededRows):
            var localRow = row
            for _ in 0..<numberOfNeededRows {
                localRow.append("")
            }
            appendEqualRow(localRow)
        }
    }
    
    
    
    
    private mutating func createInitialDataColumns(withRow row: [String], andHeaders headers: [String]) {
        
        
        for (index, nextData) in row.enumerated() {
            
            var header = ""
            
            if index >= headers.count {
                header = ""
            } else {
                header = headers[index]
            }
            let newColumn = DataColumn(header: header, data: [nextData])
            
            data.append(newColumn)
        }
    }
    
    
    private mutating func appendEqualRow(_ row: [String]) {
        
        for (index, nextNewData) in row.enumerated() {
            if data.count >= index {
                data[index].append(nextNewData)
            } else {
                data[index].append("")
            }
        }
    }
    
    
    
    
    private enum RowCompatibility {
        case dataIsEmpty
        case equalCount
        case moreColumnsThanData(Int)
        case lessColumnsThanData(Int)
        
        init(rowCount: Int, dataCount: Int) {
            if dataCount == 0 {
                self = .dataIsEmpty
                return
            }
            
            if rowCount == dataCount {
                self = .equalCount
            } else if rowCount > dataCount {
                self = .moreColumnsThanData(rowCount - dataCount)
            } else {
                self = .lessColumnsThanData(dataCount - rowCount)
            }
        }
    }
    
}

