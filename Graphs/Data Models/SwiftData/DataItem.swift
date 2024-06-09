//
//  DataItem.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

@Model
class DataItem {
    // MARK: - Properties
    //var id: UUID
    var url: URL
    
    var name: String
    
    var node: Node?
    
    @Transient
    private var resourceValues: URLResourceValues?
    
    
    // MARK: - Initialization
    init(url: URL, node: Node) {
        //self.id = UUID()
        
        self.url = url
        
        self.name = url.fileName
        
        self.node = node
    }
    
    
    func urlResources() -> URLResourceValues? {
        if resourceValues == nil {
            resourceValues = try? url.resourceValues(forKeys: [.totalFileSizeKey, .creationDateKey, .contentModificationDateKey])
        }
        
        return resourceValues
    }
}




