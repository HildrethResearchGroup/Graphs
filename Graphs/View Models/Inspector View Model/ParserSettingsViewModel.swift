//
//  Inspector_ParserSettings.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/17/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
class ParserSettingsViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var sort: [KeyPathComparator<ParserSettings>] = [.init(\.name), .init(\.creationDate)]
    
    var selection: ParserSettings? {
        get { selectionManager.selectedParserSetting }
        set { selectionManager.selectedParserSetting = newValue }
    }
    
    var parserSettings: [ParserSettings] {
        dataController.parserSettings
    }
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
}


extension ParserSettingsViewModel {
    func shouldAllowDrop(ofURLs urls: [URL]) -> Bool {
        if urls.count == 0 { return false }
        
        let allowedExtension = URL.parserSettingsFileExtension
        
        for nextURL in urls {
            if nextURL.pathExtension != allowedExtension {
                return false
            }
        }
        
        return true
    }
    
    func importURLs(_ urls: [URL]) {
        for nextURL in urls {
            _ = dataController.importParser(from: nextURL, intoNode: nil)
        }
    }
}
