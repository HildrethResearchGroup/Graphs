//
//  DGDataColumn_extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


extension DGDataColumn {
    func setDataWith(_ values: [Double]) {
        self.setDataFrom(values.map( {String($0)} ))
    }
    
    func setDataWith(_ column: DataColumn) {
        self.setDataFrom(column.data)
    }
}
