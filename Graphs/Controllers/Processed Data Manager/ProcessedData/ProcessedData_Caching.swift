//
//  ProcessedData_Caching.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


// MARK: - Load Cached Data and Graphs
extension ProcessedData {
    
    func cachedGraph() -> DGController? {
        
        guard let url = try? self.cacheGraphURL() else { return nil}
        
        let fm = FileManager()
                
        if fm.fileExists(atPath: url.path) {
            return nil
        }
        
        let controller = DGController(contentsOfFile: url.path())
        
        return controller
        }
    
    
    func loadCachedParsedData() throws {
        
        guard let url = self.cachedDataURL() else {
            throw ProcessedDataError.cacheDataURLwasNil
        }
        
        let fm = FileManager()
                
        if !fm.fileExists(atPath: url.path) {
            throw ProcessedDataError.noCachedFileAtURL
        }
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        
        let cachedParsedFile = try decoder.decode(ParsedFile.self, from: data)
        
        if cachedParsedFile.dataItemID != dataItem.id {
            throw ProcessedDataError.currentDataItemIDDoesNotMatchCachedDataID
        }
    }
    
    
    private func generateLineNumbers(upto numberOfLines: Int) -> String {
        
        let size = numberOfLines.size
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = size
        
        var output = ""
        
        for nextLineNumber in 1...numberOfLines {
            let numberString = formatter.string(from: nextLineNumber + 1 as NSNumber) ?? ""
            
            if nextLineNumber == numberOfLines {
                output.append(numberString)
            } else {
                output.append(numberString + "\n")
            }
        }
        
        return output
    }
    
    
    private func generateSimpleLineNumbers(withLines lines: [String]) -> String {
        if lines.isEmpty {
            return "0:"
        }
        
        let numberOfLines = lines.count
        
        let size = numberOfLines.size
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = size
        
        var output = ""
        var index = 1
        
        for nextLine in lines {
            let numberString = formatter.string(from: index as NSNumber) ?? ""
            
            let nextString = numberString + "\t" + nextLine
            
            if index == numberOfLines {
                output.append(nextString)
                
            } else {
                output.append(nextString + "\n")
            }
            
            index += 1
        }
        
        return output
    }
}



// MARK: - Storing Cached Data and Graphs
extension ProcessedData {
    
    // MARK: - Cache Processed Data
    func cacheData() throws {
        
        guard let targetURL = cachedDataURL() else {
            throw ProcessedDataError.cacheDataURLwasNil
        }
        
        // Create the Cache Processed Data Directory if necessary
        let cacheDirectoryURL = URL.cachedProcessedDataDirectory
        
        let fm = FileManager.default
        
        if fm.fileExists(atPath: cacheDirectoryURL.path) == false {
            try fm.createDirectory(
                at: cacheDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        // Get the Parsed File to cache
        let cachedParsedFile = parsedFile
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cachedParsedFile)
        
        // Try to save the data
        try data.write(to: targetURL)
    }
    
    
    private func cacheDataFileName() -> String {
        
        // guard let dataItem else { throw ProcessedDataError.noDataItemToCache }
        
        let fileName = dataItem.name + "-cachedData-" + dataItem.localID.uuidString
        
        return fileName
    }
    
    
    
    private func cachedDataURL() -> URL? {
        
        let fileName = cacheDataFileName()
         
        let startingURL = URL.cachedProcessedDataDirectory
        
    
        let cacheDataURL = startingURL.appending(path: fileName)
        
        return cacheDataURL
    }
}




// MARK: - Deleting Cache
extension ProcessedData {
    func deleteCache() {
        do {
            try deleteProcessedDataCache()
            
            try deleteGraphCache()
        } catch  {
            print(error)
        }
    }
    
    
    private func deleteProcessedDataCache() throws {
        
        guard let url = self.cachedDataURL() else { return }
        
        let fm = FileManager()
        
        try fm.removeItem(at: url)
    }
    
    
    private func deleteGraphCache() throws {
        let url = try self.cacheGraphURL()
        
        let fm = FileManager()
        
        try fm.removeItem(at: url)
    }
}
