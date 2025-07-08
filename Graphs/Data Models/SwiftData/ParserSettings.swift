//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class ParserSettings {
    
    var name: String
    
    var localID: UUID
    
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
            propertyChanged()
        }
    }
    
    var stringEncodingType: StringEncodingType {
        didSet {
            propertyChanged()
        }
    }
    
    var hasExperimentalDetails: Bool = false {
        didSet {
            propertyChanged()
        }
    }
    
    var experimentalDetailsSeparator: Separator {
        didSet {
            propertyChanged()
        }
    }
    
    var experimentalDetailsStart: Int = 0 {
        didSet {
            propertyChanged()
        }
    }
    
    var experimentalDetailsEnd: Int = 0 {
        didSet {
            propertyChanged()
        }
    }
    
    var hasHeader: Bool = false {
        didSet {
            propertyChanged()
        }
    }
    
    var headerSeparator: Separator {
        didSet {
            propertyChanged()
        }
    }
    
    var headerStart: Int = 0 {
        didSet {
            propertyChanged()
        }
    }
    
    var headerEnd: Int = 0 {
        didSet {
            propertyChanged()
        }
    }
    
    var hasData: Bool = false {
        didSet {
            propertyChanged()
        }
    }
    
    var dataStart: Int = 0 {
        didSet {
            propertyChanged()
        }
    }
    
    var dataSeparator: Separator {
        didSet {
            propertyChanged()
        }
    }
    
    var stopDataAtFirstEmptyLine: Bool = true {
        didSet {
            propertyChanged()
        }
    }
    
    var hasFooter: Bool = false {
        didSet {
            propertyChanged()
        }
    }
    
    
    var parserSettingsStatic: ParserSettingsStatic {
        ParserSettingsStatic(using: self)
    }
    
    
    
    // MARK: - Initializer
    init() {
        self.name = "Parser Name"
        self.localID = UUID()
        
        //self.nodes = []
        //self.dataItems = []
        
        // Date
        self.creationDate = .now
        self.lastModified = .now
       
        // String Configuration
        self.newLineType = .CRLF
        self.stringEncodingType = .ascii
        
        // Experimental Details
        self.hasExperimentalDetails = false
        self.experimentalDetailsSeparator = .comma
        self.experimentalDetailsStart = 0
        self.experimentalDetailsEnd = 0

        // Header
        self.hasHeader = false
        self.headerSeparator = .comma
        self.headerStart = 0
        self.headerEnd = 0
        
        // Data
        self.hasData = false
        self.dataSeparator = .comma
        self.dataStart = 0
        
        // Footer
        self.stopDataAtFirstEmptyLine = true
        self.hasFooter = false
        }
    
    
    init(from parserSettingsStatic: ParserSettingsStatic) {
        
        name = parserSettingsStatic.name
        localID = UUID()
        
        // Dates
        creationDate = parserSettingsStatic.creationDate
        lastModified = parserSettingsStatic.lastModified
        
        //nodes = []
        //dataItems = []
        
        // String Encoding
        newLineType = parserSettingsStatic.newLineType
        stringEncodingType = parserSettingsStatic.stringEncodingType
        
        // Experimental Details
        hasExperimentalDetails = parserSettingsStatic.hasExperimentalDetails
        experimentalDetailsSeparator = parserSettingsStatic.experimentalDetailsSeparator
        experimentalDetailsStart = parserSettingsStatic.experimentalDetailsStart
        experimentalDetailsEnd = parserSettingsStatic.experimentalDetailsEnd
        
        // Header
        hasHeader = parserSettingsStatic.hasExperimentalDetails
        headerSeparator = parserSettingsStatic.headerSeparator
        headerStart = parserSettingsStatic.headerStart
        headerEnd = parserSettingsStatic.headerEnd
        
        // Data
        hasData = parserSettingsStatic.hasData
        dataSeparator = parserSettingsStatic.dataSeparator
        dataStart = parserSettingsStatic.dataStart
        
        // Footer
        stopDataAtFirstEmptyLine = parserSettingsStatic.stopDataAtFirstEmptyLine
        hasFooter = parserSettingsStatic.hasFooter
        
    }
    
    
    func postModelContextInsertInitialization(_ node: Node?) {
        node?.setParserSetting(withInputType: .directlySet, and: self)
    }
    
    
    static func load(url: URL) throws -> ParserSettings {
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        
        let parserSettingsStatic =  try decoder.decode(ParserSettingsStatic.self, from: data)
        
        let parserSettings = ParserSettings.init(from: parserSettingsStatic)
        
        return parserSettings
    }
    
    private func propertyChanged() {
        self.lastModified = .now
        
        let nc = NotificationCenter.default
        
        let userInfo: [ String: [ParserSettings.ID]] = [Notification.UserInfoKey.parserSettingsIDs : [id]]
        
        nc.post(name: .parserSettingPropertyDidChange, object: nil, userInfo: userInfo)
    }
    
    func save(to url: URL) throws  {
        let staticParserSettings = self.parserSettingsStatic
        
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(staticParserSettings)
        
        try data.write(to: url)
    }
    
}

