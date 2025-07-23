//
//  LocalID.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/17/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftUI

protocol SelectableID: Identifiable, Hashable, Codable, Equatable {
}


protocol SelectableCheck {
    func matches(_ uuid: UUID) -> Bool
}
