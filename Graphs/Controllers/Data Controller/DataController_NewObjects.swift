//
//  DataController_NewObjects.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

extension DataController {
    func createNewParserSetting(intoNode node: Node? = nil) -> ParserSettings {
        let newParserSettings = ParserSettings()
        
        modelContext.insert(newParserSettings)
        
        if node != nil {
            node?.parserSettings = newParserSettings
        }
        
        return newParserSettings
    }
    
    
    func createNewGraphTemplate(withURL url: URL, intoNode node: Node? = nil) -> GraphTemplate {
        
        let newGraphTemplate = GraphTemplate(url: url)
       
        modelContext.insert(newGraphTemplate)
        
        if node != nil {
            node?.graphTemplate = newGraphTemplate
        }
        
        return newGraphTemplate
    }
    
}

