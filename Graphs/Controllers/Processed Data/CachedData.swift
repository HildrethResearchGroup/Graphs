//
//  CachedLines.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


struct CachedData: Codable {
    var dataItemID: DataItem.ID
    
    var lines: [String]
    var data: [[String]]
    
    init(lines: [String], data: [[String]], dataItemID: DataItem.ID) {
        
        self.lines = lines
        self.data = data
        self.dataItemID = dataItemID
    }
    
}
