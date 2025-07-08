//
//  StringEncodingType.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import OrderedCollections

enum StringEncodingType: String, Codable, CaseIterable, Identifiable {
    var id: Self {self}
    
    case automatic
    
    case ascii
    case utf8
    case utf16
    case utf32
    case unicode
    
    case iso2022JP
    case isoLatin1
    case isoLatin2
    case japaneseEUC
    case macOSRoman
    case nextstep
    case nonLossyASCII
    case shiftJIS
    case symbol
    
    case utf16BigEndian
    case utf16LittleEndian
    case utf32BigEndian
    case utf32LittleEndian
    case windowsCP1250
    case windowsCP1251
    case windowsCP1252
    case windowsCP1253
    case windowsCP1254
    
    var encoding: String.Encoding {
        switch self {
        case .automatic: return .ascii
        case .ascii: return .ascii
        case .iso2022JP: return .iso2022JP
        case .isoLatin1: return .isoLatin1
        case .isoLatin2: return .isoLatin2
        case .japaneseEUC: return .japaneseEUC
        case .macOSRoman: return .macOSRoman
        case .nextstep: return .nextstep
        case .nonLossyASCII: return .nonLossyASCII
        case .shiftJIS: return .shiftJIS
        case .symbol: return .symbol
        case .unicode: return .unicode
        case .utf16: return .utf16
        case .utf16BigEndian: return .utf16BigEndian
        case .utf16LittleEndian: return .utf16LittleEndian
        case .utf32: return .utf32
        case .utf32BigEndian: return .utf32BigEndian
        case .utf32LittleEndian: return .utf32LittleEndian
        case .utf8: return .utf8
        case .windowsCP1250: return .windowsCP1250
        case .windowsCP1251: return .windowsCP1251
        case .windowsCP1252: return .windowsCP1252
        case .windowsCP1253: return .windowsCP1253
        case .windowsCP1254: return .windowsCP1254
        }
    }
    
    /// The Primary Encodings Array contains the most likely encodings for common text files
    static var primaryEncodings: [StringEncodingType] {
        [.automatic, .ascii, .utf8, .unicode]
    }
    
    /// The Secondary Encodings Array contains all cases minus the Primary Encodings
    static var secondaryEncodings: [StringEncodingType] {
        let allCasses = OrderedSet(StringEncodingType.allCases)
        
        return Array(allCasses.subtracting(primaryEncodings))
    }
}

extension StringEncodingType: ProvidesToolTip {
    static var toolTip: String {
        "Select the type of encoding used to encode your text. ascii is one of the simpliest and common to a lot of research equipment outputs. utf8 and unicode are other common encodings.  The automatic setting will try to automatically determine the string encoding and defaults to ascii if that fails"
    }
}
