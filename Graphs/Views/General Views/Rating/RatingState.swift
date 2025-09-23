//
//  RatingState.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/23/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


enum RatingState {
    case none
    case single(Int)
    case unambiguousMultiple (Int)
    case ambiguousMultiple
}
