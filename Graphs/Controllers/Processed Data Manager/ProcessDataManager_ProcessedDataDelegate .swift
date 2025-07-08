//
//  ProcessDataManager_ProcessedDataDelegate .swift
//  Graphs
//
//  Created by Owen Hildreth on 10/21/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


// MARK: - ProcessedDataDelegate
extension ProcessDataManager: @preconcurrency ProcessedDataDelegate {
    
    
    @MainActor func cacheGraphController(_ graphController: GraphController, for dataItem: DataItem) {
        cacheManager.cacheGraphController(graphController: graphController, for: dataItem)
    }
    
    func cacheParsedFile(_ parsedFile: ParsedFile, for dataItem: DataItem) {
        cacheManager.cacheData(parsedFile: parsedFile, for: dataItem)
    }
    
    
    func cachedGraph(for dataItem: DataItem) -> DGController? {
        guard let controller = cacheManager.loadGraphController(for: dataItem) else { return nil }
        
        return controller
    }
    
    
    func cachedParsedFile(for dataItem: DataItem) -> ParsedFile? {
        let cachedParsedFile = cacheManager.loadCachedParsedData(for: dataItem)
        
        return cachedParsedFile
    }
    
    
    func deleteCache(for dataItem: DataItem) {
        cacheManager.clearCache(for: [dataItem])
    }
    
    
    func deleteCache(for dataItems: [DataItem]) {
        cacheManager.clearCache(for: dataItems)
    }
    
}
