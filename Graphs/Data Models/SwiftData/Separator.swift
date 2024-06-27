//
//  Separator.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


enum Separator: String, CaseIterable, Codable, Identifiable {
    
    var id: Self { self }
    
    /// Separates the string by a single colon.
    case colon
    
    /// Separates the string by a single comma.
    case comma
    
    /// Separates the string by a single semicolon.
    case semicolon
    
    /// Separates the string by a single space.
    case space
    
    /// Separates the string by a single tab.
    case tab
    
    /// Seperates the string by any amount of whitespace.
    case whitespace
    
    
    
    
    /// The set of characters to be used to separate a row into columns.
    var characterSet: CharacterSet {
        switch self {
        case .colon:
            return CharacterSet(charactersIn: ":")
        case .comma:
            return CharacterSet(charactersIn: ",")
        
        case .semicolon:
            return CharacterSet(charactersIn: ";")
            
        case .space:
            return CharacterSet(charactersIn: " ")
        case .tab:
            return CharacterSet(charactersIn: "\t")
        case .whitespace:
            return .whitespaces
        }
    }
    
    
    /// GUI usable name of the Separator
    var name: String {
        switch self {
        case .colon: return "Colon (:)"
        case .comma: return "Comma (,)"
        case .semicolon: return "Semicolon (;)"
        case .space: return "Single Space"
        case .tab: return "Tab (\t)"
        case .whitespace: return "Multiple Spaces"
        }
    }
}
