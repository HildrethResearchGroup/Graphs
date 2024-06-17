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
    
    @Relationship(deleteRule: .nullify, inverse: \Node.parserSettings)
    var nodes: [Node]?
    
    @Relationship(deleteRule: .nullify, inverse: \DataItem.parserSettings)
    var dataItems: [DataItem]?
    
    var hasExperimentalDetails: Bool = false
    var experimentalDetailsSeparator: SeparatorType?
    var experimentalDetailsStart: Int = 0
    var experimentalDetailsEnd: Int = 0
    
    var hasHeader: Bool = false
    var headerSepatator: SeparatorType?
    var headerStart: Int = 0
    var headerEnd: Int = 0
    
    var hasData: Bool = false
    var dataStart: Int = 0
    var dataEnd: Int = 0
    var dataSeparator: SeparatorType?
    
    
    var hasFooter: Bool = false
    
    
    
    // MARK: Initializer
    init() {
        self.name = "Parser Name"
        
        self.nodes = []
        self.dataItems = []
       

        
        self.hasExperimentalDetails = false
        
        self.experimentalDetailsStart = 0
        self.experimentalDetailsEnd = 0

        self.hasHeader = false
        self.headerSepatator = nil
        self.headerStart = 0
        self.headerEnd = 0
        
        self.hasData = false
        self.dataStart = 0
        self.dataEnd = 0

        self.hasFooter = false
        
        }
}



