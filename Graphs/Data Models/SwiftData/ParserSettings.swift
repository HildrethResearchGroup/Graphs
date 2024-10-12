//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class ParserSettings {
    
    var name: String
    
    /*
     @Relationship(deleteRule: .nullify, inverse: \Node.parserSettings)
     var nodes: [Node]?
     
     @Relationship(deleteRule: .nullify, inverse: \DataItem.parserSettings)
     var dataItems: [DataItem]?
     */
    
    
    var creationDate: Date
    var lastModified: Date
    
    var newLineType: NewLineType {
        didSet {
            updateLastModified()
        }
    }
    
    var stringEncodingType: StringEncodingType {
        didSet {
            updateLastModified()
        }
    }
    
    var hasExperimentalDetails: Bool = false {
        didSet {
            updateLastModified()
        }
    }
    
    var experimentalDetailsSeparator: Separator? {
        didSet {
            updateLastModified()
        }
    }
    
    var experimentalDetailsStart: Int = 0 {
        didSet {
            updateLastModified()
        }
    }
    
    var experimentalDetailsEnd: Int = 0 {
        didSet {
            updateLastModified()
        }
    }
    
    var hasHeader: Bool = false {
        didSet {
            updateLastModified()
        }
    }
    
    var headerSeparator: Separator? {
        didSet {
            updateLastModified()
        }
    }
    
    var headerStart: Int = 0 {
        didSet {
            updateLastModified()
        }
    }
    
    var headerEnd: Int = 0 {
        didSet {
            updateLastModified()
        }
    }
    
    var hasData: Bool = false {
        didSet {
            updateLastModified()
        }
    }
    
    var dataStart: Int = 0 {
        didSet {
            updateLastModified()
        }
    }
    
    var dataSeparator: Separator? {
        didSet {
            updateLastModified()
        }
    }
    
    var stopDataAtFirstEmptyLine: Bool = true {
        didSet {
            updateLastModified()
        }
    }
    
    var hasFooter: Bool = false {
        didSet {
            updateLastModified()
        }
    }
    
    private func updateLastModified() {
        self.lastModified = .now
    }
    
    
    // MARK: Initializer
    init() {
        self.name = "Parser Name"
        
        //self.nodes = []
        //self.dataItems = []
        
        self.creationDate = .now
        self.lastModified = .now
       
        self.newLineType = .CRLF
        self.stringEncodingType = .ascii
        
        self.hasExperimentalDetails = false
        
        self.experimentalDetailsStart = 0
        self.experimentalDetailsEnd = 0

        self.hasHeader = false
        self.headerSeparator = .comma
        self.headerStart = 0
        self.headerEnd = 0
        
        self.hasData = false
        self.dataSeparator = .comma
        self.dataStart = 0
        
        self.stopDataAtFirstEmptyLine = true
        self.hasFooter = false
        
        self.lastModified = .now
        
        }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
        
        //nodes = []
        //dataItems = []
        
        newLineType = try values.decode(NewLineType.self, forKey: .newLineType)
        stringEncodingType = try values.decode(StringEncodingType.self, forKey: .stringEncodingType)
        
        hasExperimentalDetails = try values.decode(Bool.self, forKey: .hasExperimentalDetails)
        experimentalDetailsStart = try values.decode(Int.self, forKey: .experimentalDetailsStart)
        experimentalDetailsEnd = try values.decode(Int.self, forKey: .experimentalDetailsEnd)
        
        hasHeader = try values.decode(Bool.self, forKey: .hasExperimentalDetails)
        headerSeparator = try values.decode(Separator.self, forKey: .headerSeparator)
        headerStart = try values.decode(Int.self, forKey: .headerStart)
        headerEnd = try values.decode(Int.self, forKey: .headerEnd)
        
        hasData = try values.decode(Bool.self, forKey: .hasData)
        dataSeparator = try values.decode(Separator.self, forKey: .dataSeparator)
        dataStart = try values.decode(Int.self, forKey: .dataStart)
        
        stopDataAtFirstEmptyLine = try values.decode(Bool.self, forKey: .stopDataAtFirstEmptyLine)
        hasFooter = try values.decode(Bool.self, forKey: .hasFooter)
        
        lastModified = try values.decode(Date.self, forKey: .lastModified)
    }
    
    
}


extension ParserSettings: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case creationDate
        case lastModified
        
        case newLineType
        case stringEncodingType
        case hasExperimentalDetails
        case experimentalDetailsStart
        case experimentalDetailsEnd
        
        case hasHeader
        case headerSeparator
        case headerStart
        case headerEnd
        
        case hasData
        case dataStart
        case dataSeparator
        
        case stopDataAtFirstEmptyLine
        case hasFooter
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(newLineType, forKey: .newLineType)
        try container.encode(hasExperimentalDetails, forKey: .hasExperimentalDetails)
        
        try container.encode(experimentalDetailsStart, forKey: .experimentalDetailsStart)
        try container.encode(experimentalDetailsEnd, forKey: .experimentalDetailsEnd)
        
        try container.encode(hasHeader, forKey: .hasHeader)
        try container.encode(headerSeparator, forKey: .headerSeparator)
        try container.encode(headerStart, forKey: .headerStart)
        try container.encode(headerEnd, forKey: .headerEnd)
        
        
        try container.encode(hasData, forKey: .hasData)
        try container.encode(dataStart, forKey: .dataStart)
        try container.encode(dataSeparator, forKey: .dataSeparator)
        
        try container.encode(stopDataAtFirstEmptyLine, forKey: .stopDataAtFirstEmptyLine)
        try container.encode(stopDataAtFirstEmptyLine, forKey: .stopDataAtFirstEmptyLine)
    }
    
}
