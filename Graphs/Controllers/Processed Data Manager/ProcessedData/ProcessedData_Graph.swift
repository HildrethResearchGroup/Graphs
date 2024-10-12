//
//  ProcessedData_Graph.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


extension ProcessedData {
    // MARK: - Caching Graphs
    func cacheDGController() throws {
        
        let url = try cacheGraphURL()
        
        let cacheDirectory = url.deletingLastPathComponent()
        
        // Check to see if directory exists, if not, create directory
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: cacheDirectory.path()) == false {
            try fm.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        
        try graphController?.dgController?.write(to: url)
    }
    
    
    func cacheGraphURL() throws -> URL {
        let fileName = try cacheDataGraphFileName()
        
        let startingURL = URL.cachedGraphedDataDirectory
        
        let cacheGraphURL = startingURL.appending(path: fileName)
        
        return cacheGraphURL
    }
    
    
    private func cacheDataGraphFileName() throws -> String {
        
        // guard let dataItem else { throw ProcessedDataError.noDataItemToCache }
        
        let fileName = dataItem.name + "-cachedGraph-" + dataItem.localID.uuidString
        
        return fileName
    }
    
    func graphCacheState() -> CachedState {
        guard let dateCacheLastModified = try? self.cacheGraphURL().dateLastModified else {
            return .noCache
        }
        
        guard let dateGraphTemplateLastModified = dataItem.getAssociatedGraphTemplate()?.contentModificationDate else {
            return .cacheShouldBeRemoved
        }
        
        if dateGraphTemplateLastModified > dateCacheLastModified {
            return .cacheNeedsUpdate
        } else {
            return .cachedStorageUpToDate
        }
    }
    
    
    
    // MARK: - Loading Graph
    func loadGraphController() {
        
        // TODO: Working Here
        
        let cacheState = self.graphCacheState()
        
        if cacheState == .cachedStorageUpToDate {
            let dgController = cachedGraph()
            
            self.graphController = GraphController(dgController: dgController, data: nil)
        }
        
    }
    
    
    
}
