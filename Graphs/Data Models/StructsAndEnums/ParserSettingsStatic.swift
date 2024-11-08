//
//  ParserSettingsStatic.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/19/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


struct ParserSettingsStatic: Codable, Sendable {
    var name: String
    
    var localID: UUID
    
    var creationDate: Date
    var lastModified: Date
    
    var newLineType: NewLineType
    
    var stringEncodingType: StringEncodingType
    
    var hasExperimentalDetails: Bool
    
    var experimentalDetailsSeparator: Separator
    
    var experimentalDetailsStart: Int
    
    var experimentalDetailsEnd: Int
    
    var hasHeader: Bool = false
    
    var headerSeparator: Separator
    
    var headerStart: Int
    
    var headerEnd: Int
    
    var hasData: Bool
    
    var dataStart: Int
    
    var dataSeparator: Separator
    
    var stopDataAtFirstEmptyLine: Bool
    
    var hasFooter: Bool
    
    init(using parserSettings: ParserSettings) {
        self.name = parserSettings.name
        self.localID = parserSettings.localID
        self.creationDate = parserSettings.creationDate
        self.lastModified = parserSettings.lastModified
        self.newLineType = parserSettings.newLineType
        self.stringEncodingType = parserSettings.stringEncodingType
        self.hasExperimentalDetails = parserSettings.hasExperimentalDetails
        self.experimentalDetailsSeparator = parserSettings.experimentalDetailsSeparator
        self.experimentalDetailsStart = parserSettings.experimentalDetailsStart
        self.experimentalDetailsEnd = parserSettings.experimentalDetailsEnd
        self.hasHeader = parserSettings.hasHeader
        self.headerSeparator = parserSettings.headerSeparator
        self.headerStart = parserSettings.headerStart
        self.headerEnd = parserSettings.headerEnd
        self.hasData = parserSettings.hasData
        self.dataStart = parserSettings.dataStart
        self.dataSeparator = parserSettings.dataSeparator
        self.stopDataAtFirstEmptyLine = parserSettings.stopDataAtFirstEmptyLine
        self.hasFooter = parserSettings.hasFooter
    }
    
    
    func parseLineType(for index: Int) -> ParseLineType {
        
        switch index {
        case experimentalDetailsStart...experimentalDetailsEnd:
            if self.hasExperimentalDetails {
                return .experimentalDetails
            } else {
                return .skip
            }
        case headerStart...headerEnd:
            if self.hasHeader {
                return .header
            } else {
                return .skip
            }
        case _ where index >= dataStart:
            if self.hasData {
                return .data
            } else {
                return .skip
            }
        default: return .error
        }
    }
}
