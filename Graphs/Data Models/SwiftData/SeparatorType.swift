//
//  SeparatorType.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData


@Model
class SeparatorType {
    var name: String
    var separatorLiteral: String
    
    init(seporatorLiteral: String) {
        self.name = "Separator Name"
        self.separatorLiteral = seporatorLiteral
    }
}
