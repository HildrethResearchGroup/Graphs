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
    //var id: UUID
    var url: URL
    
    var name: String
    
    var node: Node?
    
    var graphTemplate: GraphTemplate?
    
    var parserSettings: ParserSettings?
    
    var creationDate: Date
    
    @Transient
    private var resourceValues: URLResourceValues?
    
    
    // MARK: - Initialization
    init(url: URL, node: Node) {
        //self.id = UUID()
        
        self.url = url
        self.name = url.fileName
        self.node = node
        
        self.creationDate = .now
    }
    
    
    func urlResources() -> URLResourceValues? {
        if resourceValues == nil {
            resourceValues = try? url.resourceValues(forKeys: [.totalFileSizeKey, .creationDateKey, .contentModificationDateKey])
        }
        
        return resourceValues
    }
}


