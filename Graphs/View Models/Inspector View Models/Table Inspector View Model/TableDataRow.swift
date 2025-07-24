//
//  TableDataRow.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/24/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


struct TableDataRow: Identifiable, Hashable {
    var id = ID()
    
    let rowNumber: Int
    
    struct ID: Identifiable, Hashable {
        var id = UUID()
    }
}
