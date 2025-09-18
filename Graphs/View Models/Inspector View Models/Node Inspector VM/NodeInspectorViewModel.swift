//
//  NodeInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/19/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


@Observable
@MainActor
class NodeInspectorViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    
    var nodes: [Node] {
        get { dataController.selectedNodes }
    }
    
    var nodesCount: Int {
        nodes.count
    }
    
    var availableParserSettings: [ParserSettings] {
        get { dataController.parserSettings }
    }
    
    var availableGraphTemplates: [GraphTemplate] {
        get { dataController.graphTemplates }
    }
    
    var name: String {
        get {
            switch nodesCount {
            case 0: return "No Selection"
            case 1: return nodes.first?.name ?? "No Name"
            default: return "Multiple Selection"
            }
        }
        
        set {
            if name != newValue {
                if nodesCount == 1 {
                    if let onlyNode = nodes.first {
                        onlyNode.name = newValue
                    }
                }
            }
        }
    }
    
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        
        self.name = ""
        
        setInitialName()
    }
    
    
    private func setInitialName() {
        switch nodesCount {
        case 0: name = "No Selection"
        case 1: name = nodes.first?.name ?? "No Name"
        default: name = "Multiple Selection"
        }
    }
    
    
    // MARK: - Name Content
    func updateNames() {
        for nextNode in nodes {
            nextNode.name = name
        }
    }
    
    var disableNameTextfield: Bool {
        switch nodesCount {
        case 0: return true
        case 1: return false
        default: return true
        }
    }
    
    var disableSettingsUpdate: Bool {
        switch nodesCount {
        case 0: return true
        case 1: return false
        default: return true
        }
    }
    
    func selectedNodeDidChange() {
        setInitialName()
    }
    
}


// MARK: - Settings
extension NodeInspectorViewModel {
    // MARK: - Parser Selection
    
    func updateParserSetting(with inputType: InputType, and newParserSettings: ParserSettings?) {
        for nextNode in nodes {
            
            nextNode.setParserSetting(withInputType: inputType, and: newParserSettings)
        }
    }
    
    /*
     var parserSettingsName: String {
         switch nodesCount {
         case 0: return ""
         case 1:
             guard let node = nodes.first else { return "No Selection" }
             
             switch node.parserSettingsInputType {
             case .none:
                 return "No Parser Set"
             case .defaultFromParent:
                 return "From Parent: \(node.getAssociatedParserSettings()?.name ?? "None")"
             case .directlySet:
                 return node.getAssociatedParserSettings()?.name ?? "Unnamed Parser"
             }
         
         default: return "Multiple Selection"
         }
     }
     */
    
    
    
    var parserSettingsMenuText: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            guard let onlyNode = nodes.first else { return ""}
            switch onlyNode.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return inheritParserSettingsName
            case .directlySet: return " \(onlyNode.getAssociatedParserSettings()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    var inheritParserSettingsName: String {
        guard let node = nodes.first else { return "Inherit:"}
        if let parserSettings = node.getAssociatedParserSettings() {
            return "Inherit: \(parserSettings.name)"
        } else {
            return "Inherit: Folder needs Template"
        }
    }
    
    
    
    // MARK: - Graph Template Selection
    func updateGraphtemplate(with inputType: InputType, and newGraphTemplate: GraphTemplate?) {
        for nextNode in nodes {
            nextNode.setGraphTemplate(withInputType: inputType, and: newGraphTemplate)
        }
    }
    
   
    var graphMenuText: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            guard let onlyNode = nodes.first else { return ""}
            switch onlyNode.graphTemplateInputType {
            case .none: return "None"
            case .defaultFromParent: return inheritGraphTemplateName
            case .directlySet: return " \(onlyNode.getAssociatedGraphTemplate()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    var inheritGraphTemplateName: String {
        guard let node = nodes.first else { return "Inherit:"}
        if let template = node.getAssociatedGraphTemplate() {
            return "Inherit: \(template.name)"
        } else {
            return "Inherit: Folder needs Template"
        }
    }
    
    
    var inheritButtonDisabled: Bool {
        switch nodesCount {
        case 0: return true
        case 1:
            guard let onlyNode = nodes.first else { return true }
            if onlyNode.parent == nil {
                return true
            } else {
                return false
            }
        default: return true
        }
    }
    
}


// MARK: - UI
extension NodeInspectorViewModel {
    
    
    var folderPath: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            let nodePath = dataController.selectedNodes.first?.nodePath() ?? ""
            return nodePath
        default: return "Multiple Selection"
        }
    }
    
    
    var toolTip_ParserSettings: String {
        let defaultOutput = "Set Parser for Folder"
        let numberOfSelectedNodes = selectionManager.selectedNodeIDs.count
        
        switch numberOfSelectedNodes {
        case 0: return defaultOutput
        case 1:
            guard let node = dataController.selectedNodes.first else {
                return defaultOutput
            }
            
            return "Set Parser for \(node.name) Folder"
        default: return defaultOutput + "s"
        }
    }
    
    
    var toolTip_GraphTemplate: String {
        let defaultOutput = "Set Graph for Folder"
        let numberOfSelectedNodes = selectionManager.selectedNodeIDs.count
        
        switch numberOfSelectedNodes {
        case 0: return defaultOutput
        case 1:
            guard let node = dataController.selectedNodes.first else {
                return defaultOutput
            }
            
            return "Set Graph for \(node.name) Folder"
        default: return defaultOutput + "s"
        }
    }
}
