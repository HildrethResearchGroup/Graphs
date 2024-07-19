//
//  DataItemsInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

@Observable
class DataItemsInspectorViewModel {
    
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var dataItems: [DataItem] {
        get { dataController.selectedDataItems }
    }
    
    
    var name: String {
        didSet {
            if dataItems.count == 1 {
                if let onlyDataItem = dataItems.first {
                    onlyDataItem.name = name
                }
            }
        }
    }
    
    
    // MARK: - Initializers
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.name = ""
        
        setInitialName()
    }
    
    
    private func setInitialName() {
        switch dataController.selectedDataItems.count {
        case 0: name = "No Selection"
        case 1: name = dataController.selectedDataItems.first?.name ?? "No Name"
        default: name = "Multiple Selection"
        }
    }
    
    
    // MARK: - Name Content
    func updateNames() {
        for nextDataItem in dataItems {
            nextDataItem.name = name
        }
    }
    
    var disableNameTextfield: Bool {
        if dataController.selectedDataItems.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - FilePath Content
    var filePath: String {
        switch dataController.selectedDataItems.count {
        case 0: return "No Selection"
        case 1: return dataController.selectedDataItems.first?.url.path() ?? "No Filepath Could be Created"
        default: return "Multiple Selection"
        }
    }
    
    var disableNameFilepath: Bool {
        switch dataController.selectedDataItems.count {
        case 0: return true
        case 1: return false
        default: return true
        }
    }
    
    
    // MARK: - Parser Selection Content
    func availableParsers() -> [String] {
        var output = ["None", "From Parent"]
        
        output.append(contentsOf: dataController.parserSettings.map( {$0.name} ))
        
        return output
    }
    
    
    
}


extension UserDefaults {
    static let showUpdateNamesAlertKey = "showUpdateNamesAlertKey"
}
