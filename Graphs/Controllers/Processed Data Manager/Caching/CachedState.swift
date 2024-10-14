//
//  CachedState.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


enum CachedState {
    case noCache
    case cacheNeedsUpdate
    case cachedStorageUpToDate
    case cacheShouldBeRemoved
}
