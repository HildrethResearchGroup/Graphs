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
    
    @Relationship(deleteRule: .nullify, inverse: \Node.graphTemplate)
    var node: [Node]?
    
    @Relationship(deleteRule: .nullify, inverse: \DataItem.graphTemplate)
    var dataItems: [DataItem]?
    
    init(name: String? = nil, url: URL) {
        self.name = name ?? url.fileName
        self.url = url
    }
}
