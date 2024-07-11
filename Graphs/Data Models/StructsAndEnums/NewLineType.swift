//
//  NewLineType.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


/// Type of New Line character representation.
///
/// https://en.wikipedia.org/wiki/Newline
enum NewLineType: String, Codable, CaseIterable, Identifiable {
    var id: Self {self}
    
    case LF
    case CRLF
    case CR
    case LFCR
    
    var shouldSkipLines: Bool {
        switch self {
        case .LF: return false  // Default for macOS
        case .CRLF: return true // Default for Windows
        case .CR: return false  // Classic macOS and macOS 9
        case .LFCR: return true // Risc OS
        }
    }
    
    var stringLiteral: String {
        switch self {
        case .LF: return "\n"
        case .CRLF: return "\r\n"
        case .CR: return "\r"
        case .LFCR: return "\n\r"
        }
    }
}

extension NewLineType: PresentableName {
    var name: String {
        switch self {
        case .LF: return "\\n"
        case .CRLF: return "\\r\\n"
        case .CR: return "\\r"
        case .LFCR: return "\\n\\r"
        }
    }
}

extension NewLineType: ProvidesToolTip {
    var toolTip: String {
        "Modern macOS uses \\n as the new line character, but other operating systems, such as Windows, might use a different character set to designate a new line.  Sometimes, this causes the file Parser to add empty lines.  Change this property if the Parser is adding or missing lines.  Note, macOS applications use \\n to indicate a new line while Windows applications typically use \\r\\n to indicate a new line.  More information can be found on Wikipedia at: https://en.wikipedia.org/wiki/Newline"
    }
}
