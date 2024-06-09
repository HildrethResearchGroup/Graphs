//
//  DataItem_FileProperties.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData


// MARK: - File Properties
extension DataItem {

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
    var creationDate: Date {
        return urlResources()?.creationDate ?? .distantPast
    }
    
    
    @Transient
    var contentModificationDate: Date {
        return urlResources()?.contentModificationDate ?? .distantPast
    }
    
    @Transient
    var nodeName: String {
        return node?.name ?? "No Folder"
    }
}
