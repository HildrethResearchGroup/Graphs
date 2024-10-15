//
//  CacheManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/12/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import OSLog



class CacheManager {
    static let shared = CacheManager()
}


// MARK: - Data Caching
extension CacheManager {
    
    
    func parsedFileCacheState(for dataItem: DataItem) -> CachedState {
        guard let dateCacheLastModified = self.cachedDataURL(for: dataItem)?.dateLastModified else {
            return .noCache
        }
        
        guard let dateParserSettingsLastModified = dataItem.getAssociatedParserSettings()?.lastModified else {
            return .cacheShouldBeRemoved
        }
        
        if dateParserSettingsLastModified > dateCacheLastModified {
            return .cacheNeedsUpdate
        } else {
            return .cachedStorageUpToDate
        }
        
    }
    
    
    private func cacheDataFileName(for dataItem: DataItem) -> String {
        let fileName = dataItem.name + "-cachedData-" + dataItem.localID.uuidString
        
        return fileName
    }
    
    
    private func cachedDataURL(for dataItem: DataItem) -> URL? {
        let fileName = cacheDataFileName(for: dataItem)
         
        let startingURL = URL.cachedProcessedDataDirectory
        
    
        let cacheDataURL = startingURL.appending(path: fileName)
        
        return cacheDataURL
    }
    
    
    func cacheData(parsedFile: ParsedFile, for dataItem: DataItem) {
        guard let targetURL = cachedDataURL(for: dataItem) else {
            return
        }
        
        // Create the Cache Processed Data Directory if necessary
        let cacheDirectoryURL = URL.cachedProcessedDataDirectory
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: cacheDirectoryURL.path) == false {
            do {
                try fm.createDirectory(
                    at: cacheDirectoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch  {
                let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
                logger.error("Could not create cache directory: \(cacheDirectoryURL.path())")
                logger.error("\(error.localizedDescription)")
                return
            }
            
        }
        
        
        // Get the Parsed File to cache
        let cachedParsedFile = parsedFile
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(cachedParsedFile) else {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not encode cached Parsed File")
            return
        }
        
        
        // Try to save the data
        do {
            try data.write(to: targetURL)
        } catch  {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not write cached parsed file to: \(targetURL.path())")
            logger.error("\(error.localizedDescription)")
        }
    }
    
    
    func loadCachedParsedData(for dataItem: DataItem) -> ParsedFile? {
        
        switch self.parsedFileCacheState(for: dataItem) {
        case .noCache: return nil
        case .cacheNeedsUpdate: return nil
        case .cachedStorageUpToDate: break
        case .cacheShouldBeRemoved: return nil
        }
        
        
        guard let cacheURL = try? self.cacheGraphURL(for: dataItem) else {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not create get cached parsed data url for: \(dataItem.name)")
            return nil
        }
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: cacheURL.path()) {
            return nil
        }
        
        guard let data = try? Data(contentsOf: cacheURL) else {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not get cached parsed data from: \(cacheURL)")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        var cachedParsedFile: ParsedFile? = nil
        
        do {
            cachedParsedFile = try decoder.decode(ParsedFile.self, from: data)
        } catch  {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not created cached parsed data from: \(cacheURL)")
            
            return cachedParsedFile
        }
        
        
        
        if cachedParsedFile?.dataItemID != dataItem.id {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Current DataItem ID does not Match Cached DataItem ID")
            
            return nil
        }
        
        return cachedParsedFile
        
    }
    
    private func cacheGraphOutOfDate(for dataItem: DataItem) {
        
    }
    
    // TODO: Implement cache removal when out of date
    
}



// MARK: - Graph Caching
extension CacheManager {
    
    func graphCacheState(for dataItem: DataItem) -> CachedState {
        guard let dateCacheLastModified = try? self.cacheGraphURL(for: dataItem).dateLastModified else {
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
    
    
    private func cacheDataGraphFileName(for dataItem: DataItem) throws -> String {
        
        // guard let dataItem else { throw ProcessedDataError.noDataItemToCache }
        
        let fileName = dataItem.name + "-cachedGraph-" + dataItem.localID.uuidString
        
        return fileName
    }
    
    
    private func cacheGraphURL(for dataItem: DataItem) throws -> URL {
        let fileName = try cacheDataGraphFileName(for: dataItem)
        
        let startingURL = URL.cachedGraphedDataDirectory
        
        let cacheGraphURL = startingURL.appending(path: fileName)
        
        return cacheGraphURL
    }
    
    
    func cacheDGController(dgController: DGController, for dataItem: DataItem) {
        
        guard let targetURL = try? cacheGraphURL(for: dataItem) else { return }
        
        let cacheDirectoryURL = targetURL.deletingLastPathComponent()
        
        
        // Check to see if directory exists, if not, create directory
        let fm = FileManager.default
        if fm.fileExists(atPath: cacheDirectoryURL.path()) == false {
            do {
                try fm.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
            } catch  {
                let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
                logger.error("Could not create cache directory: \(cacheDirectoryURL.path())")
                logger.error("\(error.localizedDescription)")
                return
            }
        }
        
        // Write Data Graph file
        do {
            try dgController.write(to: targetURL)
        } catch {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Could not write cached parsed file to: \(targetURL.path())")
            logger.error("\(error.localizedDescription)")
            return
        }
    }
    
    
    func loadGraphController(for dataItem: DataItem) -> DGController? {
        let cacheState = self.graphCacheState(for: dataItem)
        
        if cacheState != .cachedStorageUpToDate {
            return nil
        }
        
        guard let cacheURL = try? cacheGraphURL(for: dataItem) else { return nil }
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: cacheURL.path()) {
            return nil
        }
        
        let controller = DGController(contentsOfFile: cacheURL.path())
        
        return controller
        
    }
}



// MARK: - Deleting Cache
extension CacheManager {
    
    func clearCache(for dataItems: [DataItem]) {
        self.deleteProcessedDataCache(for: dataItems)
        self.deleteGraphCache(for: dataItems)
    }
    
    func emptyEntireCache() {
        let url = URL.cacheStorageDirectory
        
        do {
            let fm = FileManager.default
            try fm.removeItem(at: url)
        } catch  {
            let logger = Logger(subsystem: "edu.HRG.Graphs", category: "Caching")
            logger.error("Cannot remove entire Cache direcotry at: \(url)")
        }
        
    }
    
    
    private func deleteProcessedDataCache(for dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            guard let url = self.cachedDataURL(for: nextDataItem) else { return }
            
            let fm = FileManager.default
            
            do {
                try fm.removeItem(at: url)
            } catch {
                return
            }
        }
    }
    
    
    private func deleteGraphCache(for dataItems: [DataItem]) {
        for nextDataItem in dataItems {
            guard let url = try? self.cacheGraphURL(for: nextDataItem) else { return }
            
            let fm = FileManager.default
            
            do {
                try fm.removeItem(at: url)
            } catch {
                return
            }
        }
    }
    
}
