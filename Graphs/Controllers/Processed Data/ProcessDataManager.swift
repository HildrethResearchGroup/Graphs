//
//  ProcessDataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/23/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


struct ProcessDataManager {
    
    var cachedData: [DataItem.ID : ProcessedData] = [:]
    
    
    
    func loadData(for dataItem: DataItem) {
        
    }
    
}


struct ProcessedData: Codable {
    
    var dataItemID: DataItem.ID
    
    var lineNumbers: [String] = []
    var lines: [String] = []
    var simpleNumberLines: String = ""
    
    var data: [[String]] = []
    
    var dgController: DGController?
    var dataItem: DataItem?
    
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dataItemID = try values.decode(DataItem.ID.self, forKey: .dataItemID)
        self.lineNumbers = try values.decode([String].self, forKey: .lineNumbers)
        self.lines = try values.decode([String].self, forKey: .lines)
        self.simpleNumberLines = try values.decode(String.self, forKey: .simpleNumberLines)
        self.data = try values.decode([[String]].self, forKey: .data)
        
        self.dgController = nil
        self.dataItem = nil
    
    }
    
    enum CodingKeys: CodingKey {
        case dataItemID
        case lineNumbers
        case lines
        case simpleNumberLines
        case data
    }
    
}

extension ProcessedData {
    mutating func loadCachedData(from url: URL) throws {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        
        let localData = try decoder.decode(ProcessedData.self, from: data)
        
        if localData.dataItemID != self.dataItemID {
            throw ProcessedDataError.dataItemIDDoesNotMatchCachedData
        }
        
        self.lineNumbers = localData.lineNumbers
        self.lines = localData.lines
        self.simpleNumberLines = localData.simpleNumberLines
        self.data = localData.data
    }
    
    
    
    mutating func loadDGController(from url: URL) throws {
        let localDGController = DGController(contentsOfFile: url.path())
        
        self.dgController = localDGController
    }
    
    
    
    func cacheData(to url: URL) throws {
        var encoder = JSONEncoder()
        
        let data = try encoder.encode(self)
        
        try data.write(to: url)
    }
    
    func cacheDGController(to url: URL) throws {
        try dgController?.write(to: url)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(dataItemID, forKey: .dataItemID)
        try container.encode(lineNumbers, forKey: .lineNumbers)
        try container.encode(lines, forKey: .lines)
        try container.encode(simpleNumberLines, forKey: .simpleNumberLines)
        try container.encode(data, forKey: .data)
        
    }
    
    enum ProcessedDataError: Error {
        case dataItemIDDoesNotMatchCachedData
    }
}
