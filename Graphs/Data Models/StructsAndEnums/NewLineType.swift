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
        case .LF: return false
        case .CRLF: return true
        case .CR: return false
        case .LFCR: return true
        }
    }
}

extension NewLineType: PresentableName {
    var name: String {
        switch self {
        case .LF: return "LF: \\n"
        case .CRLF: return "CR LF: \\r\\n"
        case .CR: return "CR: \\r"
        case .LFCR: return "LF CR: \\n\\r"
        }
    }
}

extension NewLineType: ProvidesToolTip {
    var toolTip: String {
        "Modern macOS uses \\n as the new line character, but other operating systems, such as Windows, might use a different character set to designate a new line.  Sometimes, this causes the file Parser to add empty lines.  Change this property if the Parser is adding or missing lines.  Note, Windows uses \\r\\n to indicate a new line."
    }
}
