//
//  ProccessedData_Error.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/11/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


// MARK: - Errors
extension ProcessedData {
    enum ProcessedDataError: Error {
        case currentDataItemIDDoesNotMatchCachedDataID
        case noDataItemToCache
        case cacheURLInputShouldBeDirectory
        case noCachedFileAtURL
        case cacheDataURLwasNil
        case cacheGraphURLwasNil
    }
}
