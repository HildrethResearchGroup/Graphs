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
    var localID: UUID
    
    var originalURL: URL?
    
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \Node.subNodes)
    var parent: Node?
    
    //@Relationship(deleteRule: .cascade, inverse: \Node.parent)
    var subNodes: [Node]? = []
    
    @Relationship(deleteRule: .nullify, inverse: \DataItem.node)
    var dataItems: [DataItem]
    
    var creationDate: Date
    
    var bookmarkData: Data?
    
    
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
    
    
    // MARK: - Initializers
    init(url: URL?) {
        self.localID = UUID()

        self.originalURL = url
        
        self.dataItems = []
        
        self.creationDate = .now
        

        self.subNodes = []
        
        self.name = url?.lastPathComponent ?? Node.defaultName
        
        
        // Set initial input types.  This will be updated using postModelContextInsertInitialization
        self.parent = nil
        parserSettingsInputType = .none
        graphTemplateInputType = .none
    }
    
    
    func postModelContextInsertInitialization(_ parent: Node?) {
        
        self.setParent(parent)
        
        if let parent {
            if parent.parent == nil {
                self.graphTemplateInputType = .defaultFromParent
                self.parserSettingsInputType = .defaultFromParent
            } else {
                self.graphTemplateInputType = parent.graphTemplateInputType
                self.parserSettingsInputType = parent.parserSettingsInputType
            }
        } else {
            parserSettingsInputType = .none
            graphTemplateInputType = .none
        }
    }
    
    
    func setParent(_ node: Node?) {
        if let node {
            
            if node.subNodes != nil {
                self.parent = node
            } else {
                node.subNodes = []
                self.parent = node
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
        
        let oldValue = self.parserSettings
        
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
        
        let nc = NotificationCenter.default
        
        let dataItemIDS = flattenedDataItems().map({ $0.id })
        
        let info: [String: Any] = [
            Notification.UserInfoKey.dataItemIDs : dataItemIDS,
            
            Notification.UserInfoKey.oldParserSettingLocalID : oldValue?.localID ?? UUID(uuidString: "1234") as Any,
            
            Notification.UserInfoKey.newParserSettingLocalID : parserSettings?.localID ?? UUID(uuidString: "1234") as Any
        ]
        
        nc.post(name: .parserOnNodeOrDataItemDidChange, object: nil, userInfo: info)
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



