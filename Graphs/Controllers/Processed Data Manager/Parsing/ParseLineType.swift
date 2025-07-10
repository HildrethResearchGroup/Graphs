//
//  ParseLineType.swift
//  Graphs
//
//  Created by Owen Hildreth on 11/6/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


enum ParseLineType {
    case end
    case error
    case experimentalDetails
    case data
    case header
    case skip
    
    
    
}

import SwiftUI
extension ParseLineType {
    var color: Color {
        switch self {
        case .data: Color.blue
        case .experimentalDetails: Color.green
        case .header: Color.cyan
        default: Color.black
        }
    }
}
