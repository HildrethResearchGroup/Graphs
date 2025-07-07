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
    var localID: UUID
    var url: URL
    
    var name: String
    
    var node: Node?
    
    private var graphTemplate: GraphTemplate? {
        didSet {
            let nc = NotificationCenter.default
            
            let info: [String: Any] = [
                "dataItem.ids" : [id],
                
                "oldGraphTemplate.id" : oldValue.id,
                
                "newGraphTemplate.id" : graphTemplate.id
            ]
            
            nc.post(name: .graphTemplateDidChange, object: nil, userInfo: info)
        }
    }
    
    private var parserSettings: ParserSettings? {
        didSet {
            let nc = NotificationCenter.default
            
            let info: [String: Any] = [
                Notification.UserInfoKey.dataItemIDs : [id],
                
                Notification.UserInfoKey.oldParserSettingID : oldValue.id,
                
                Notification.UserInfoKey.newParserSettingID : parserSettings.id
            ]
            
            nc.post(name: .parserOnDataItemDidChange, object: nil, userInfo: info)
        }
    }
    
    
    var creationDate: Date
    
    var graphTemplateInputType: InputType
    
    var parserSettingsInputType: InputType
    
    var bookmarkData: Data?
    
    @Transient
    private var resourceValues: URLResourceValues?
    
    
    
    // MARK: - Initialization
    init(url: URL) {
        self.localID = UUID()
        
        self.url = url
        self.name = url.fileName ?? "No File Name"
        self.node = nil
        
        self.creationDate = .now
        self.graphTemplateInputType = .none
        self.parserSettingsInputType = .none
        
        bookmarkData = self.setBookmarkData()
    }
    
    
    func postModelContextInsertInitialization(_ node: Node?) {
        self.node = node
        
        if node != nil {
            self.graphTemplateInputType = .defaultFromParent
            self.parserSettingsInputType = .defaultFromParent
        }
    }
    
    func setBookmarkData() -> Data? {
        
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope)
            return bookmarkData
        } catch  {
            print(error)
            return nil
        }
    }
    
    
    // MARK: - URL Resources
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
    
    
    func cacheStorageDirectory() -> URL {
        var location = URL.cacheStorageDirectory
        
        let dataItemFolder = String(self.name + "-" + self.localID.uuidString)
        
        
        location.append(path: dataItemFolder)
        
        return location
    }
}


// MARK: - Accessing Content and BookMarkData

extension DataItem {
    func bookMarkURL() -> URL? {
        guard let bookmarkData else { return nil }
        
        var bookmarkDataIsStale: Bool = false
        
        do {
            let outputURL = try URL(resolvingBookmarkData: bookmarkData,
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &bookmarkDataIsStale)
            
            return outputURL
        } catch  {
            print("Error resolving bookmark data: \(error)")
            print("Bookmark Status = \(bookmarkDataIsStale ? "Stale" : "Not Stale")")
            return nil
        }
        
    }
}
