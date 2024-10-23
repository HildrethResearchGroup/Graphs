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
    
    var experimentalDetailsSeparator: Separator? {
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
    
    var headerSeparator: Separator? {
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
    
    var dataSeparator: Separator? {
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
    
    
    init(from parserSettingsStatic: ParserSettingsStatic) {
        
        name = parserSettingsStatic.name
        localID = parserSettingsStatic.localID
        creationDate = parserSettingsStatic.creationDate
        
        //nodes = []
        //dataItems = []
        
        newLineType = parserSettingsStatic.newLineType
        stringEncodingType = parserSettingsStatic.stringEncodingType
        
        hasExperimentalDetails = parserSettingsStatic.hasExperimentalDetails
        experimentalDetailsStart = parserSettingsStatic.experimentalDetailsStart
        experimentalDetailsEnd = parserSettingsStatic.experimentalDetailsEnd
        
        hasHeader = parserSettingsStatic.hasExperimentalDetails
        headerSeparator = parserSettingsStatic.headerSeparator
        headerStart = parserSettingsStatic.headerStart
        headerEnd = parserSettingsStatic.headerEnd
        
        hasData = parserSettingsStatic.hasData
        dataSeparator = parserSettingsStatic.dataSeparator
        dataStart = parserSettingsStatic.dataStart
        
        stopDataAtFirstEmptyLine = parserSettingsStatic.stopDataAtFirstEmptyLine
        hasFooter = parserSettingsStatic.hasFooter
        
        lastModified = parserSettingsStatic.lastModified
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

