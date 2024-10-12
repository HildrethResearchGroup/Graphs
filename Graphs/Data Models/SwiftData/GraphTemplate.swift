//
//  GraphTemplate.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Model
class GraphTemplate {
    var name: String
    var url: URL
    
    /*
     @Relationship(deleteRule: .nullify, inverse: \Node.graphTemplate)
     var node: [Node]?
     
     @Relationship(deleteRule: .nullify, inverse: \DataItem.graphTemplate)
     var dataItems: [DataItem]?
     */
    
    
    var creationDate: Date
    
    init?(name: String? = nil, url: URL) {
        
        if url.pathExtension != URL.dataGraphFileExtension {
            return nil
        }
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: url.path()) == false {
            return nil
        }
        
        self.name = name ?? url.fileName
        self.url = url
        self.creationDate = .now
    }
    
    
    @Transient
    private var resourceValues: URLResourceValues?
    
    
}

extension GraphTemplate {
    
    func urlResources() -> URLResourceValues? {
        if resourceValues == nil {
            resourceValues = try? url.resourceValues(forKeys: [.totalFileSizeKey, .creationDateKey, .contentModificationDateKey])
        }
        
        return resourceValues
    }
    
    
    @Transient
    var fileSize: Int {
        urlResources()?.totalFileSize ?? 0
    }
    
    
    @Transient
    var scaledFileSize: String {
        //Source: https://stackoverflow.com/questions/42722498/print-the-size-megabytes-of-data-in-swift
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB, .useGB]
        bcf.countStyle = .file
        
        return bcf.string(fromByteCount: Int64(fileSize))
    }
    
    @Transient
    var contentCreationDate: Date {
        return urlResources()?.creationDate ?? .distantPast
    }
    
    
    @Transient
    var contentModificationDate: Date {
        return urlResources()?.contentModificationDate ?? .distantPast
    }
}

