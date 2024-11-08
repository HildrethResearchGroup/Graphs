//
//  ProcessedData_Parsing.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

extension ProcessedData {
    // MARK: - Load ParsedFile
    func loadParsedFile() async throws -> ParsedFile? {
        
        var parsedfile: ParsedFile? = nil
        
        // TODO: Fix local state loading
        /*
         switch parsedFileState {
         case .noTemplate: parsedfile = nil
         case .upToDate: parsedfile = self.parsedFile
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
         */
        
        
        // Temporary.  Remove caching
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
        
        return parsedfile
    }
}
