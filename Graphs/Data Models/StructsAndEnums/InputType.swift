//
//  GraphTemplateType.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/19/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

enum InputType: String, Codable, Identifiable, Hashable {
    var id: Self { self }
    
    case none
    case defaultFromParent
    case directlySet
}
