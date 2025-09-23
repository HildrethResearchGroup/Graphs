//
//  DataItemsInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import Collections

@Observable
@MainActor
class DataItemsInspectorViewModel {
    
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var dataItems: [DataItem] {
        get { dataController.selectedDataItems }
    }
    
    
    var availableParserSettings: [ParserSettings] {
        get { dataController.parserSettings }
    }
    
    var availableGraphTemplates: [GraphTemplate] {
        get { dataController.graphTemplates }
    }
    
    
    var name: String {
        get {
            setInitialName()
        }
        set {
            if newValue != name {
                if dataItems.count == 1 {
                    if let onlyDataItem = dataItems.first {
                        onlyDataItem.name = newValue
                    }
                }
            }
        }
    }
    
    var folderName: String {
        if dataItems.count == 1 {
            return dataItems.first?.nodePath ?? ""
        } else if dataItems.count > 1 {
            let folderNames = Set(dataItems.map({ $0.nodePath}))
            
            if folderNames.count == 1 {
                return folderNames.first ?? ""
            } else {
                return "Multiple Nodes"
            }
        }
        else {
            return ""
        }
    }
    
    var folderPath: String {
        if dataItems.count == 1 {
            return dataItems.first?.nodePath ?? ""
        } else if dataItems.count > 1 {
            let folderNames = Set(dataItems.map({ $0.nodePath}))
            
            if folderNames.count == 1 {
                return folderNames.first ?? ""
            } else {
                return "Multiple Nodes"
            }
        }
        else {
            return ""
        }
    }
    
    
    var userNotes: String {
        get {
            switch dataItems.count {
            case 0: return ""
            case 1:
                guard let dataItem = dataItems.first else { return "" }
                return dataItem.userNotes
            default: return "Notes can only be edited for one data file at a time"
            }
        }
        set {
            if dataItems.count == 1 {
                guard let dataItem = dataItems.first else { return }
                dataItem.userNotes = newValue
            }
        }
    }
    
    
    var dataItemsCount: Int {
        dataItems.count
    }
    
    
    
    // MARK: - Initializers
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.name = ""
        
        self.name = setInitialName()
    }
    
    
    private func setInitialName() -> String {
        switch dataItemsCount {
        case 0: return "No Selection"
        case 1: return dataController.selectedDataItems.first?.name ?? "No Name"
        default: return "Multiple Selection"
        }
    }
    
    
    func selectedNodeDidChange() {
        name = setInitialName()
    }
    
    // MARK: - Name Content
    func updateNames() {
        for nextDataItem in dataItems {
            nextDataItem.name = name
        }
    }
    
    
    var disableNameTextfield: Bool {
        if dataItemsCount == 0 {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - FilePath Content
    var filePath: String {
        switch dataItemsCount {
        case 0: return ""
        case 1: return dataController.selectedDataItems.first?.url.path(percentEncoded: false) ?? "No Filepath Could be Created"
        default: return "Multiple Selection"
        }
    }
    
    var truncatedFilePath: String {
        switch dataItemsCount {
        case 0: return ""
        case 1: return dataController.selectedDataItems.first?.url.truncatedPath ?? "No Filepath Could be Created"
        default: return "Multiple Selection"
        }
    }
    
    var disableNameFilepath: Bool {
        switch dataItemsCount {
        case 0: return true
        case 1: return false
        default: return true
        }
    }
    
    var disableSettingsUpdate: Bool {
        if dataItemsCount == 0 {
            return true
        } else {
            return false
        }
    }
}



// MARK: - Settings
extension DataItemsInspectorViewModel {
    // MARK: - Parser Selection
    
    func updateParserSetting(with inputType: InputType, and newParserSettings: ParserSettings?) {
        for nextDataItem in dataItems {
            nextDataItem.setParserSetting(withInputType: inputType, and: newParserSettings)
        }
    }
    
    
    var parserSettingsMenuText: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return ""}
            switch dataItem.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return inheritParserSettingsName
            case .directlySet: return "\(dataItem.getAssociatedParserSettings()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    var inheritParserSettingsName: String {
        guard let dataItem = dataController.selectedDataItems.first else { return "Inherit"}
        if let parserSettings = dataItem.getAssociatedParserSettings() {
            return "Inherit: \(parserSettings.name)"
        } else {
            return "Inherit: Folder needs Template"
        }
    }
    
    
    
    // MARK: - Graph Template Selection
    func updateGraphtemplate(with inputType: InputType, and newGraphTemplate: GraphTemplate?) {
        for nextDataItem in dataItems {
            nextDataItem.setGraphTemplate(withInputType: inputType, and: newGraphTemplate)
        }
    }
    
    
    var graphMenuText: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return ""}
            switch dataItem.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return inheritGraphTemplateName
            case .directlySet: return "\(dataItem.getAssociatedGraphTemplate()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    var inheritGraphTemplateName: String {
        guard let dataItem = dataController.selectedDataItems.first else { return "Inherit:"}
        if let template = dataItem.getAssociatedGraphTemplate() {
            return "Inherit: \(template.name)"
        } else {
            return "Inherit: Folder needs Template"
        }
    }
}


// MARK: - Open in Finder
extension DataItemsInspectorViewModel {
    func openInFinder() {
        let urls = dataItems.map({ $0.url})
        urls.showInFinder()
    }
}

extension UserDefaults {
    static let showUpdateNamesAlertKey = "showUpdateNamesAlertKey"
}


// MARK: - Tool Tips
extension DataItemsInspectorViewModel {
    var toolTip_ParserSettings: String {
        let defaultOutput = "Set Parser for Data"
        let numberOfSelectedDataItems = selectionManager.selectedDataItemIDs.count
        
        switch numberOfSelectedDataItems {
        case 0: return defaultOutput
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else {
                return defaultOutput
            }
            
            return "Set Parser for \(dataItem.name) Data"
        default: return defaultOutput
        }
    }
    
    
    var toolTip_GraphTemplate: String {
        let defaultOutput = "Set Graph for Data"
        let numberOfSelectedDataItems = selectionManager.selectedDataItemIDs.count
        
        switch numberOfSelectedDataItems {
        case 0: return defaultOutput
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else {
                return defaultOutput
            }
            
            return "Set Graph for \(dataItem.name) Data"
        default: return defaultOutput
        }
    }
    
    var toolTip_openFiles: String {
        let defaultOutput = "Show files in Finder"
        let numberOfSelectedDataItems = selectionManager.selectedDataItemIDs.count
        
        switch numberOfSelectedDataItems {
        case 0: return defaultOutput
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else {
                return defaultOutput
            }
            
            return "Show \(dataItem.name) in Finder"
        default: return defaultOutput
        }
    }
    
    // MARK: - Disabled UI
    var disabled_userNotes: Bool {
        if dataItems.count == 1 {
            return false
        } else {
            return true
        }
    }
}

