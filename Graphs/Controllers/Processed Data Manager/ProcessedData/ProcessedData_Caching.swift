//
//  ProcessedData_Caching.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


// MARK: - Cached Data and Graphs
extension ProcessedData {
    
    func cacheProcessedData() throws {
        cacheGraphController()
        cacheParsedFile()
    }
    
    
    func cacheGraphController() {
        
        guard let graphController else { return }
        
        delegate?.cacheGraphController(graphController, for: dataItem)
    }
    
    
    func cacheParsedFile() {
        guard let parsedFile else { return }
        
        delegate?.cacheParsedFile(parsedFile, for: dataItem)
    }
    
    
    func cachedParsedData() throws -> ParsedFile? {
        
        switch self.parsedFileState {
            case .noTemplate: return nil
            case .outOfDate: return nil
            default: break
        }
        
        let cachedParsedFile = delegate?.cachedParsedFile(for: dataItem)
        
        return cachedParsedFile
    }
    
}


