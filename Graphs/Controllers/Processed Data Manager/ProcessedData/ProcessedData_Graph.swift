//
//  ProcessedData_Graph.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import OSLog


extension ProcessedData {
    // MARK: - Caching Graphs
    
    func graphCacheState() -> CachedState {
        let cm = CacheManager()
        
        return cm.graphCacheState(for: dataItem)
    }
    
    
    // MARK: - Load ParsedFile
    @MainActor
    func loadParsedFile() async throws -> ParsedFile? {
        
        var parsedfile: ParsedFile? = nil
        
        switch parsedFileState {
        case .noTemplate: parsedfile = nil
        case .upToDate: parsedfile = nil
        case .processing: return nil
        case .notProcessed, .outOfDate:
            
            self.parsedFileState = .processing
            
            guard let staticParserSettings = dataItem.getAssociatedParserSettings()?.parserSettingsStatic else {
                self.parsedFileState = .noTemplate
                parsedfile = nil
                
                return parsedfile
            }
            
            let dataItemURL = dataItem.url
            let dataItemID = dataItem.localID
            //let dataItemName = dataItem.name
            
            parsedfile = try await Parser.parse(dataItemURL, using: staticParserSettings, into: dataItemID)
            
            self.parsedFileState = .upToDate
        }
        
        return parsedfile
    }
    
    
    
    
    // MARK: - Loading Graph
    func loadGraphController() {
        
        let cacheState = self.graphCacheState()
        
        if cacheState == .cachedStorageUpToDate {
            let controller = delegate?.cachedGraph(for: dataItem)
            
            let parsedFile = self.parsedFile
                
            self.graphController = GraphController(dgController: controller, data: parsedFile?.data)
        }
        
    }
}
