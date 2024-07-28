//
//  ProcessedData.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


class ProcessedData {
    
    var dataItem: DataItem
    
    var lineNumbers = ""
    var lines: [String] = []
    var simpleNumberLines: String = ""
    
    var data: [[String]] = []
    
    var dgController: DGController?
    
    init(dataItem: DataItem) {
        self.dataItem = dataItem
        
        
    }
    
}


// MARK: - Load Cached Data and Graphs
extension ProcessedData {
    
    func loadDGController() throws {
        
        let url = try self.cacheGraphURL()
        
        let fm = FileManager()
                
        if !fm.fileExists(atPath: url.path) {
            throw ProcessedDataError.noCachedFileAtURL
        }
                
        let localDGController = DGController(contentsOfFile: url.path())
        
        self.dgController = localDGController
    }
    
    
    func loadCachedProcessedData() throws {
        
        let url = try self.cachedDataURL()
        
        let fm = FileManager()
                
        if !fm.fileExists(atPath: url.path) {
            throw ProcessedDataError.noCachedFileAtURL
        }
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        
        let cachedLines = try decoder.decode(CachedData.self, from: data)
        
        if cachedLines.dataItemID != dataItem.id {
            throw ProcessedDataError.currentDataItemIDDoesNotMatchCachedDataID
        }
        
        self.lines = cachedLines.lines
        
        self.lineNumbers = generateLineNumbers(upto: cachedLines.lines.count)
        
        self.simpleNumberLines = generateSimpleLineNumbers(withLines: cachedLines.lines)
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
    
    // MARK: Cache Processed Data
    func cacheData() throws {
                
        let targetURL = try cachedDataURL()
                
        let cachedLines = CachedData(lines: self.lines, data: self.data, dataItemID: dataItem.id)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cachedLines)
        
        try data.write(to: targetURL)
    }
    
    
    private func cacheDataFileName() throws -> String {
        
        let fileName = dataItem.name + "-cachedData-" + dataItem.localID.uuidString
        
        return fileName
    }
    
    
    private func cachedDataURL() throws -> URL {
        
        let fileName = try cacheDataFileName()
        
        let startingURL = URL.cachedProcessedDataDirectory
        
        let fm = FileManager()
                
        if !fm.fileExists(atPath: startingURL.path) {
            try fm.createDirectory(
                at: startingURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        let cacheDataURL = startingURL.appending(path: fileName)
        
        return cacheDataURL
    }
    
    
    
    // MARK: Caching Graphs
    func cacheDGController() throws {
        
        let url = try cacheGraphURL()
        
        try dgController?.write(to: url)
    }
    
    
    private func cacheGraphURL() throws -> URL {
        let fileName = try cacheDataGraphFileName()
        
        let startingURL = URL.cachedGraphedDataDirectory
        
        let fm = FileManager()
                
        if !fm.fileExists(atPath: startingURL.path) {
            try fm.createDirectory(
                at: startingURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        let cacheGraphURL = startingURL.appending(path: fileName)
        
        return cacheGraphURL
    }
    
    
    private func cacheDataGraphFileName() throws -> String {
        let fileName = dataItem.name + "-cachedGraph-" + dataItem.localID.uuidString
        
        return fileName
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
        
        let url = try self.cachedDataURL()
        
        let fm = FileManager()
        
        try fm.removeItem(at: url)
    }
    
    
    private func deleteGraphCache() throws {
        let url = try self.cacheGraphURL()
        
        let fm = FileManager()
        
        try fm.removeItem(at: url)
    }
}




// MARK: - Errors
extension ProcessedData {
    enum ProcessedDataError: Error {
        case currentDataItemIDDoesNotMatchCachedDataID
        case noDataItemToCache
        case cacheURLInputShouldBeDirectory
        case noCachedFileAtURL
    }
}
