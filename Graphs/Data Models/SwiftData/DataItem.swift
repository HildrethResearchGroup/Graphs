//
//  DataItem.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Model
final class DataItem: Identifiable, Hashable {
    // MARK: - Properties
    //var id: UUID
    var url: URL
    
    var name: String
    
    var node: Node?
    
    private var graphTemplate: GraphTemplate?
    
    private var parserSettings: ParserSettings?
    
    var creationDate: Date
    
    var graphTemplateInputType: InputType
    
    var parserSettingsInputType: InputType
    
    
    @Transient
    private var resourceValues: URLResourceValues?
    
    
    // MARK: - Initialization
    init(url: URL, node: Node) {
        //self.id = UUID()
        
        self.url = url
        self.name = url.fileName
        self.node = node
        
        self.creationDate = .now
        self.graphTemplateInputType = .defaultFromParent
        self.parserSettingsInputType = .defaultFromParent
    }
    
    
    func urlResources() -> URLResourceValues? {
        if resourceValues == nil {
            resourceValues = try? url.resourceValues(forKeys: [.totalFileSizeKey, .creationDateKey, .contentModificationDateKey])
        }
        
        return resourceValues
    }
    
    
    func setGraphTemplate(withInputType inputType: InputType, and newGraphTemplate: GraphTemplate?) {
        self.graphTemplateInputType = inputType
        
        switch inputType {
        case .none:
            self.graphTemplate = nil
        case .defaultFromParent:
            self.graphTemplate = nil
        case .directlySet:
            if let newGraphTemplate {
                self.graphTemplate = newGraphTemplate
            } else {
                self.graphTemplateInputType = .none
                self.graphTemplate = nil
            }
        }
    }
    
    
    func getAssociatedGraphTemplate() -> GraphTemplate? {
        switch graphTemplateInputType {
        case .none: return nil
        case .directlySet: return self.graphTemplate
        case .defaultFromParent:
            return node?.getAssociatedGraphTemplate()
        }
    }
    
    
    func setParserSetting(withInputType inputType: InputType, and newParserSettings: ParserSettings?) {
        
        self.parserSettingsInputType = inputType
        
        switch inputType {
        case .none:
            self.parserSettings = nil
        case .defaultFromParent:
            self.parserSettings = nil
        case .directlySet:
            if let newParserSettings {
                self.parserSettings = newParserSettings
            } else {
                self.parserSettingsInputType = .none
                self.parserSettings = nil
            }
        }
    }
    
    
    func getAssociatedParserSettings() -> ParserSettings? {
        switch parserSettingsInputType {
        case .none: return nil
        case .directlySet: return self.parserSettings
        case .defaultFromParent: return node?.getAssociatedParserSettings()
        }
    }

}


