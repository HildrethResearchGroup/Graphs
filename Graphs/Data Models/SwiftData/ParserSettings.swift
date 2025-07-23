//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ParserSettings {
    
    var name: String
    
    var localID: ParserSettings.LocalID
    
    /*
     @Relationship(deleteRule: .nullify, inverse: \Node.parserSettings)
     var nodes: [Node]?
     
     @Relationship(deleteRule: .nullify, inverse: \DataItem.parserSettings)
     var dataItems: [DataItem]?
     */
    
    
    var creationDate: Date
    var lastModified: Date
    
    
    // DidSet not working in SwiftData anymore
    @Transient
    var newLineType: NewLineType {
        get { _newLineType }
        set {
            _newLineType = newValue
            propertyChanged()
        }
    }
    private var _newLineType: NewLineType
    
    
    @Transient
    var stringEncodingType: StringEncodingType {
        get { _stringEncodingType }
        set {
            _stringEncodingType = newValue
            propertyChanged()
        }
    }
    private var _stringEncodingType: StringEncodingType
    
    @Transient
    var hasExperimentalDetails: Bool {
        get { _hasExperimentalDetails }
        set {
            _hasExperimentalDetails = newValue
            propertyChanged()
        }
    }
    private var _hasExperimentalDetails: Bool = false
    
    @Transient
    var experimentalDetailsSeparator: Separator {
        get { _experimentalDetailsSeparator }
        set {
            _experimentalDetailsSeparator = newValue
            propertyChanged()
        }
    }
    private var _experimentalDetailsSeparator: Separator
    
    
    @Transient
    var experimentalDetailsStart: Int {
        get { _experimentalDetailsStart }
        set {
            _experimentalDetailsStart = newValue
            propertyChanged()
        }
    }
    private var _experimentalDetailsStart: Int
    
    
    @Transient
    var experimentalDetailsEnd: Int {
        get { _experimentalDetailsEnd }
        set {
            _experimentalDetailsEnd = newValue
            propertyChanged()
        }
    }
    private var _experimentalDetailsEnd: Int = 0
    
    
    @Transient
    var hasHeader: Bool{
        get { _hasHeader }
        set {
            _hasHeader = newValue
            propertyChanged()
        }
    }
    private var _hasHeader: Bool = false
    
    
    @Transient
    var headerSeparator: Separator {
        get { _headerSeparator }
        set {
            _headerSeparator = newValue
            propertyChanged()
        }
    }
    private var _headerSeparator: Separator
    
    
    
    @Transient
    var headerStart: Int {
        get { _headerStart }
        set {
            _headerStart = newValue
            propertyChanged()
        }
    }
    private var _headerStart: Int = 0
    
    
    @Transient
    var headerEnd: Int {
        get { _headerEnd }
        set {
            _headerEnd = newValue
            propertyChanged()
        }
    }
    private var _headerEnd: Int = 0
    
    
    @Transient
    var hasData: Bool {
        get { _hasData }
        set {
            _hasData = newValue
            propertyChanged()
        }
    }
    private var _hasData: Bool = false
    
    
    @Transient
    var dataStart: Int {
        get { _dataStart }
        set {
            _dataStart = newValue
            propertyChanged()
        }
    }
    private var _dataStart: Int = 0
    
    
    @Transient
    var dataSeparator: Separator {
        get { _dataSeparator }
        set {
            _dataSeparator = newValue
            propertyChanged()
        }
    }
    private var _dataSeparator: Separator
    
    
    @Transient
    var stopDataAtFirstEmptyLine: Bool {
        get { _stopDataAtFirstEmptyLine }
        set {
            _stopDataAtFirstEmptyLine = newValue
            propertyChanged()
        }
    }
    private var _stopDataAtFirstEmptyLine: Bool = true
    
    
    @Transient
    var hasFooter: Bool {
        get { _hasFooter }
        set {
            _hasFooter = newValue
            propertyChanged()
        }
    }
    private var _hasFooter: Bool = false
    
   
    var parserSettingsStatic: ParserSettingsStatic {
        ParserSettingsStatic(using: self)
    }
  
    
    
    
    // MARK: - Initializer
    init() {
        self.name = "Parser Name"
        self.localID = LocalID()
        
        //self.nodes = []
        //self.dataItems = []
        
        // Date
        self.creationDate = .now
        self.lastModified = .now
       
        // String Configuration
        self._newLineType = .CRLF
        self._stringEncodingType = .ascii
        
        // Experimental Details
        self._hasExperimentalDetails = false
        self._experimentalDetailsSeparator = .comma
        self._experimentalDetailsStart = 0
        self._experimentalDetailsEnd = 0

        // Header
        self._hasHeader = false
        self._headerSeparator = .comma
        self._headerStart = 0
        self._headerEnd = 0
        
        // Data
        self._hasData = false
        self._dataSeparator = .comma
        self._dataStart = 0
        
        // Footer
        self._stopDataAtFirstEmptyLine = true
        self._hasFooter = false
        }
    
    
    init(from parserSettingsStatic: ParserSettingsStatic) {
        
        name = parserSettingsStatic.name
        localID = LocalID()
        
        // Dates
        creationDate = parserSettingsStatic.creationDate
        lastModified = parserSettingsStatic.lastModified
        
        //nodes = []
        //dataItems = []
        
        // String Encoding
        _newLineType = parserSettingsStatic.newLineType
        _stringEncodingType = parserSettingsStatic.stringEncodingType
        
        // Experimental Details
        _hasExperimentalDetails = parserSettingsStatic.hasExperimentalDetails
        _experimentalDetailsSeparator = parserSettingsStatic.experimentalDetailsSeparator
        _experimentalDetailsStart = parserSettingsStatic.experimentalDetailsStart
        _experimentalDetailsEnd = parserSettingsStatic.experimentalDetailsEnd
        
        // Header
        _hasHeader = parserSettingsStatic.hasExperimentalDetails
        _headerSeparator = parserSettingsStatic.headerSeparator
        _headerStart = parserSettingsStatic.headerStart
        _headerEnd = parserSettingsStatic.headerEnd
        
        // Data
        _hasData = parserSettingsStatic.hasData
        _dataSeparator = parserSettingsStatic.dataSeparator
        _dataStart = parserSettingsStatic.dataStart
        
        // Footer
        _stopDataAtFirstEmptyLine = parserSettingsStatic.stopDataAtFirstEmptyLine
        _hasFooter = parserSettingsStatic.hasFooter
        
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
        
        let userInfo: [ String: [ParserSettings.LocalID]] = [Notification.UserInfoKey.parserSettingsIDs : [localID]]
        
        nc.post(name: .parserSettingPropertyDidChange, object: nil, userInfo: userInfo)
    }
    
    func save(to url: URL) throws  {
        let staticParserSettings = self.parserSettingsStatic
        
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(staticParserSettings)
        
        try data.write(to: url)
    }
    
}


// MARK: - LocalID
extension ParserSettings: SelectableCheck {
    struct LocalID: SelectableID, Codable, Identifiable, Transferable, Equatable, Hashable {
        
        var id = UUID()
        var uuidString: String {
            id.uuidString
        }
        
        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .uuid)
                ProxyRepresentation(exporting: \.id)
            }
    }
    
    func matches(_ uuid: UUID) -> Bool {
        return localID.id == uuid
    }
}
