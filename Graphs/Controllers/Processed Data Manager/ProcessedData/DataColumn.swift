//
//  DataColumn.swift
//  Graphs
//
//  Created by Owen Hildreth on 11/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation

struct DataColumn: Codable, Sendable {
    var header: String
    var data: [String]
    
    init() {
        header = ""
        data = []
    }
    
    init(header: String, data: [String]) {
        self.header = header
        self.data = data
    }
    
    init(headers: [String], data: [String] = []) {
        self.init()
        
        let collapsedHeader = collapseHeader(headers)
        
        self.init(header: collapsedHeader, data: data)
    }
    
    
    init(headers: [String], emptyRows: Int) {
        let emptyColumn: [String] = Array(repeating: "", count: emptyRows)
        
        self.init(headers: headers, data: emptyColumn)
    }
    
    private func collapseHeader(_ headers: [String]) -> String {
        let header = headers.joined(separator: "\n")
        return header
    }
    
    
    
    mutating func append(_ dataIn: String) {
        data.append(dataIn)
    }
    
    
    
}
