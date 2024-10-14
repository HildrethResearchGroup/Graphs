//
//  CacheManager_Errors.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/13/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

// MARK: - Cache Manager Errors
extension CacheManager {
    
    enum CacheManagerError: Error {
        case cacheDataURLwasNil
        case currentDataItemIDDoesNotMatchCachedDataID
    }
    
}

