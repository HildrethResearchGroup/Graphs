//
//  DataItemsInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import Collections

@Observable
@MainActor
class DataItemsInspectorViewModel {
    
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var dataItems: OrderedSet<DataItem> {
        get { dataController.selectedDataItems }
    }
    
    
    var availableParserSettings: [ParserSettings] {
        get { dataController.parserSettings }
    }
    
    var availableGraphTemplates: [GraphTemplate] {
        get { dataController.graphTemplates }
    }
    
    
    var name: String {
        didSet {
            if name != oldValue {
                if dataItems.count == 1 {
                    if let onlyDataItem = dataItems.first {
                        onlyDataItem.name = name
                    }
                }
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
        
        setInitialName()
    }
    
    
    private func setInitialName() {
        switch dataItemsCount {
        case 0: name = "No Selection"
        case 1: name = dataController.selectedDataItems.first?.name ?? "No Name"
        default: name = "Multiple Selection"
        }
    }
    
    
    func selectedNodeDidChange() {
        setInitialName()
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
        case 1: return dataController.selectedDataItems.first?.url.path() ?? "No Filepath Could be Created"
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
    
    var parserSettingsName: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return "No Selection" }
            
            switch dataItem.parserSettingsInputType {
            case .none:
                return "No Parser Set"
            case .defaultFromParent:
                return "From Parent: \(dataItem.getAssociatedParserSettings()?.name ?? "None")"
            case .directlySet:
                return dataItem.getAssociatedParserSettings()?.name ?? "Unnamed Parser"
            }
        
        default: return "Multiple Selection"
        }
    }
    
    
    var parserSettingsMenuText: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return ""}
            switch dataItem.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return "Inhert"
            case .directlySet: return "Set to: \(dataItem.getAssociatedParserSettings()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    
    // MARK: - Graph Template Selection
    func updateGraphtemplate(with inputType: InputType, and newGraphTemplate: GraphTemplate?) {
        for nextDataItem in dataItems {
            nextDataItem.setGraphTemplate(withInputType: inputType, and: newGraphTemplate)
        }
    }
    
    
    var graphTemplateName: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return "No Selection" }
            
            switch dataItem.graphTemplateInputType {
            case .none:
                return "No Graph Selected"
            case .defaultFromParent:
                return "From Parent: \(dataItem.getAssociatedGraphTemplate()?.name ?? "None")"
            case .directlySet:
                return dataItem.getAssociatedGraphTemplate()?.name ?? "Unnamed Graph Template"
            }
        
        default: return "Multiple Selection"
        }
    }
    
    var graphMenuText: String {
        switch dataItemsCount {
        case 0: return ""
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else { return ""}
            switch dataItem.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return "Inhert"
            case .directlySet: return "Set to: \(dataItem.getAssociatedGraphTemplate()?.name ?? "")"
            }
        default: return ""
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
