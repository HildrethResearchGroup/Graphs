//
//  ProcessedData_Caching.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
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




// MARK: - Moved to LineNumberViewModel

/*
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
 */
