//
//  DataColumn.swift
//  Graphs
//
//  Created by Owen Hildreth on 11/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation

struct DataColumn: Codable, Sendable, Identifiable {
    var id = ID()
    
    /// Header for the Data Column.
    private(set) var header: String
    
    /// Data as an array of Strings.
    ///
    /// Data added through the `append` functions.
    private(set) var data: [String]
    
    /// Creates an empty DataColumn.
    init() {
        header = ""
        data = []
    }
    
    /// Creates a DataColumn with the given header and data.
    init(header: String, data: [String]) {
        self.header = header
        self.data = data
    }
    
    
    /// Creates a DataColumn with the given header array and data.
    ///
    /// The header array wil be collapsed into a single string with \\n inserted between the header rows to create a single header string.
    init(headers: [String], data: [String] = []) {
        self.init()
        
        let collapsedHeader = collapseHeader(headers)
        
        self.init(header: collapsedHeader, data: data)
    }
    
    /// Creates a DataColumn with the headers and with `emptyRows` number of empty rows.
    init(headers: [String], emptyRows: Int) {
        let emptyColumn: [String] = Array(repeating: "", count: emptyRows)
        
        self.init(headers: headers, data: emptyColumn)
    }

    
    
    /// Collapses the header array of strings to a single string with \\n added to separate each header.
    private func collapseHeader(_ headers: [String]) -> String {
        let header = headers.joined(separator: "\n")
        return header
    }
    
    
    /// Appends a single data into the data array.
    mutating func append(_ dataIn: String) {
        data.append(dataIn)
    }
    
    /// Appends an array of data into the data array
    mutating func append(_ dataIn: [String]) {
        data.append(contentsOf: dataIn)
    }
    
    func data(for rowNumber: Int) -> String {
        if rowNumber >= data.count {
            return ""
        } else {
            return data[rowNumber - 1]
        }
    }
    
    
    struct ID: Identifiable, Hashable, Codable {
        var id = UUID()
    }
}
