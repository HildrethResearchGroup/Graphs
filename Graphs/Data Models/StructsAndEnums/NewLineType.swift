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
    
    /// Automatic replacement of \r\n with \n
    case auto
    
    /// Default for macOS: \n
    case LF
    
    /// Default for Windows: \r\n
    case CRLF
    
    /// Classic macOS and macOS 9: \r
    case CR
    
    /// Risc OS: "\n\r"
    case LFCR
    
    var shouldSkipLines: Bool {
        switch self {
        case .auto: return false
        case .LF: return false  // Default for macOS
        case .CRLF: return true // Default for Windows
        case .CR: return false  // Classic macOS and macOS 9
        case .LFCR: return true // Risc OS
        }
    }
    
    var stringLiteral: String {
        switch self {
        case .auto: return "\n"
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
        case .auto: return "automatic"
        case .LF: return "\\n"
        case .CRLF: return "\\r\\n"
        case .CR: return "\\r"
        case .LFCR: return "\\n\\r"
        }
    }
}

extension NewLineType: ProvidesToolTip {
    static var toolTip: String {
        "automatic: Automatically replaces \\r\\n with \\n. \nmacOS: \\n \nWindows: \\r\\n \nModern macOS uses \\n as the new line character, but other operating systems, such as Windows, might use a different character set to designate a new line.  Sometimes, this causes the file Parser to add empty lines.  Change this property if the Parser is adding or missing lines.\nNote 1: The Auto setting is slower and more memory intensive.\nNote 2: Windows Applications (such as Excel) still use \\r\\n even when running on macOS.\nNote 3: More information on newline characters can be found on Wikipedia at: https://en.wikipedia.org/wiki/Newline."
    }
}
