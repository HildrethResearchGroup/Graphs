//
//  FolderItem.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Node {
    // MARK: - Properties
    var id: UUID
    
    var originalURL: URL?
    
    var name: String
    
    var parent: Node?
    
    @Relationship(deleteRule: .cascade, inverse: \Node.parent)
    var subNodes: [Node]? = []
    
    @Relationship(deleteRule: .nullify, inverse: \DataItem.node)
    var dataItems: [DataItem]
    
    var creationDate: Date
    
    
    private var graphTemplate: GraphTemplate? {
        didSet {
            let nc = NotificationCenter.default
            
            let dataItemIDS = flattenedDataItems().map({ $0.id })
            
            let info: [String: Any] = [
                Notification.UserInfoKey.dataItemIDs : dataItemIDS,
                
                Notification.UserInfoKey.oldGraphTemplateID : oldValue.id,
                
                Notification.UserInfoKey.newGraphTemplateID : parserSettings.id
            ]
            
            nc.post(name: .graphTemplateDidChange, object: nil, userInfo: info)
        }
    }
    
    
    
    var graphTemplateInputType: InputType
    
    private var parserSettings: ParserSettings? {
        didSet {
            let nc = NotificationCenter.default
            
            let dataItemIDS = flattenedDataItems().map({ $0.id })
            
            let info: [String: Any] = [
                Notification.UserInfoKey.dataItemIDs : dataItemIDS,
                
                Notification.UserInfoKey.oldParserSettingID : oldValue.id,
                
                Notification.UserInfoKey.newParserSettingID : parserSettings.id
            ]
            
            nc.post(name: .parserOnNodeOrDataItemDidChange, object: nil, userInfo: info)
        }
    }
    
    var parserSettingsInputType: InputType
    
    
    var nodeTypeStorage: Int
    
    @Transient
    var nodeType: NodeType {
        set {
            nodeTypeStorage = newValue.intForStorage()
        } get {
            NodeType(rawValue: nodeTypeStorage) ?? .child
        }
    }
    
    
    // MARK: - Initializers
    init(url: URL?, parent: Node?) {
        self.id = UUID()

        self.originalURL = url
        
        if parent?.subNodes == nil {
            parent?.subNodes = []
        }
        
        self.parent = parent
        
        self.dataItems = []
        
        self.creationDate = .now
        
        if parent == nil {
            nodeTypeStorage = NodeType.root.intForStorage()
        } else {
            nodeTypeStorage = NodeType.child.intForStorage()
        }
        
        // TODO: Implement Subnodes
        self.subNodes = []
        
        self.name = url?.fileName ?? Node.defaultName
        
        
        if parent != nil {
            parserSettingsInputType = .defaultFromParent
            graphTemplateInputType = .defaultFromParent
        } else {
            parserSettingsInputType = .none
            graphTemplateInputType = .none
        }
    }
    
    
    func setParent(_ node: Node?) {
        if let node {
            if node.subNodes != nil {
                node.subNodes?.append(self)
            } else {
                node.subNodes = []
                node.subNodes?.append(self)
            }
        }
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
            return parent?.getAssociatedGraphTemplate()
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
        case .defaultFromParent:
            return parent?.getAssociatedParserSettings()
        }
    }
    

    
    func flattenedDataItems() -> [DataItem] {
        
        var localItems: [DataItem] = self.dataItems
        
        let allSubNodes = self.flattendSubNodes()
        
        for nextSubNode in allSubNodes {
            localItems.append(contentsOf: nextSubNode.flattenedDataItems())
        }
        
        return localItems
    }
    
    
    func flattendSubNodes() -> [Node] {
        let localSubNodes: [Node] = self.subNodes ?? []
        
        var output: [Node] = localSubNodes
        
        for nextSubNodes in localSubNodes {
            output.append(contentsOf: nextSubNodes.flattendSubNodes())
        }
        
        return output
    }
}


extension Node: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Node {
    static let defaultName = "New Node"
}


// MARK: - Node Types
extension Node {
    enum NodeType: Int {
        case root = 0
        case child = 1
        
        init?(rawValue: Int) {
            if rawValue == 0 {
                self = .root
            } else {
                self = .child
            }
        }
        
        func intForStorage() -> Int {
            switch self {
            case .root: return 0
            case .child: return 1
            }
        }
    }
}
