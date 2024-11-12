//
//  NodeInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/19/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
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
        didSet {
            if name != oldValue {
                if nodesCount == 1 {
                    if let onlyNode = nodes.first {
                        onlyNode.name = name
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
    
    
    var parserSettingsMenuText: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            guard let onlyNode = nodes.first else { return ""}
            switch onlyNode.parserSettingsInputType {
            case .none: return "None"
            case .defaultFromParent: return "Inhert"
            case .directlySet: return " \(onlyNode.getAssociatedParserSettings()?.name ?? "")"
            }
        default: return ""
        }
    }
    
    
    
    // MARK: - Graph Template Selection
    func updateGraphtemplate(with inputType: InputType, and newGraphTemplate: GraphTemplate?) {
        for nextNode in nodes {
            nextNode.setGraphTemplate(withInputType: inputType, and: newGraphTemplate)
        }
    }
    
    
    var graphTemplateName: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            guard let onlyNode = nodes.first else { return "No Selection" }
            
            switch onlyNode.graphTemplateInputType {
            case .none:
                return "No Graph Set"
            case .defaultFromParent:
                return "From Parent: \(onlyNode.getAssociatedGraphTemplate()?.name ?? "None")"
            case .directlySet:
                return onlyNode.getAssociatedGraphTemplate()?.name ?? "Unnamed Graph Template"
            }
        
        default: return "Multiple Selection"
        }
    }
    
    var graphMenuText: String {
        switch nodesCount {
        case 0: return ""
        case 1:
            guard let onlyNode = nodes.first else { return ""}
            switch onlyNode.graphTemplateInputType {
            case .none: return "None"
            case .defaultFromParent: 
                if let template = onlyNode.getAssociatedGraphTemplate() {
                    return "Inhereted: \(template.name)"
                } else {
                    return "Inhert: Folder needs Template"
                }
            case .directlySet: return " \(onlyNode.getAssociatedGraphTemplate()?.name ?? "")"
            }
        default: return ""
        }
    }
    
}
