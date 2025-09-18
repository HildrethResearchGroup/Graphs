//
//  ProcessingState.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/10/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


enum ProcessingState {
    case none
    case outOfDate
    case inProgress
    case upToDate
    
    
}

extension ProcessingState: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: ""
        case .outOfDate: "Out of Date"
        case .inProgress: "Processing"
        case .upToDate: "Up to Date"
        }
    }
}
