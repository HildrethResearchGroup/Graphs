//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

struct Parser {
    
    static func parse(_ url: URL, using staticSettings: ParserSettingsStatic, into id: UUID) async throws -> ParsedFile {
        var lines: [String] = []
        
        var experimentalDetails = ""
        var header: [[String]] = []
        var data: [[String]] = []
        
        var footer = ""
        
        var index = 0
        
        for try await nextLine in url.lines {
            lines.append(nextLine)
            
            lines.append(nextLine)
            
            
            if try lineIsExperimentalDetails(index: index, staticParseSettings: staticSettings) {
                experimentalDetails.append("\n")
                experimentalDetails.append(nextLine)
            } else if try lineIsHeader(index: index, staticParseSettings: staticSettings) {
                guard let separator = staticSettings.headerSeparator else { throw ParserError.noHeaderSeparator }
                
                let nextheaderLine = try parse(line: nextLine, withSeparator: separator)
                header.append(nextheaderLine)
            } else if try lineIsData(index: index, staticParseSettings: staticSettings) {
                guard let separator = staticSettings.headerSeparator else { throw ParserError.noDataSeparator }
                
                let nextDataLine = try parse(line: nextLine, withSeparator: separator)
                
                data.append(nextDataLine)
            } else {
                footer.append("\n")
                footer.append(nextLine)
            }
            
            index += 1
        }
        
        // Set the number of lines using the index
        let numberOfColumns = data.first?.count ?? 0
        
        return ParsedFile(dataItemID: id,
                          experimentDetails: experimentalDetails,
                          header: header,
                          data: data,
                          footer: footer,
                          numberOfColumns: numberOfColumns)

    }
    
    /*
     static func parseDataItem(_ dataItem: DataItem) async throws -> ParsedFile {
         
         var lines: [String] = []
         
         var experimentalDetails = ""
         var header: [[String]] = []
         var data: [[String]] = []
         
         var footer = ""
         

         guard let parserSettings = dataItem.getAssociatedParserSettings() else {throw ParserError.noParseSettings}
         
         
         var index = 0
         
         for try await nextLine in dataItem.url.lines {
             lines.append(nextLine)
             
             
             if try lineIsExperimentalDetails(index: index, parseSettings: parserSettings) {
                 experimentalDetails.append("\n")
                 experimentalDetails.append(nextLine)
             } else if try lineIsHeader(index: index, parseSettings: parserSettings) {
                 guard let separator = parserSettings.headerSeparator else { throw ParserError.noHeaderSeparator }
                 
                 let nextheaderLine = try parse(line: nextLine, withSeparator: separator)
                 header.append(nextheaderLine)
             } else if try lineIsData(index: index, parseSettings: parserSettings) {
                 guard let separator = parserSettings.headerSeparator else { throw ParserError.noDataSeparator }
                 
                 let nextDataLine = try parse(line: nextLine, withSeparator: separator)
                 
                 data.append(nextDataLine)
             } else {
                 footer.append("\n")
                 footer.append(nextLine)
             }
             
             index += 1
         }
         
         // Set the number of lines using the index
         let numberOfColumns = data.first?.count ?? 0
         
         return ParsedFile(dataItemID: dataItem.id,
                           experimentDetails: experimentalDetails,
                           header: header,
                           data: data,
                           footer: footer,
                           numberOfColumns: numberOfColumns)
     }
     */
   
    
    
    private static func lineIsExperimentalDetails(index: Int, staticParseSettings: ParserSettingsStatic) throws -> Bool {
        
        if staticParseSettings.experimentalDetailsSeparator == nil {throw ParserError.noExperimentalDetailsSeparator}
        
        if staticParseSettings.hasExperimentalDetails == false {return false }
        
        return try indexInRange(index, startRange: staticParseSettings.experimentalDetailsStart, endRange: staticParseSettings.experimentalDetailsStart)
    }
    
    private static func lineIsHeader(index: Int, staticParseSettings : ParserSettingsStatic) throws -> Bool {
        
        if staticParseSettings.headerSeparator == nil {throw ParserError.noHeaderSeparator}
        
        if staticParseSettings.hasHeader == false {return false}
        
        return try indexInRange(index, startRange: staticParseSettings.headerStart, endRange: staticParseSettings.headerEnd)
    }
    
    
    
    private static func lineIsData(index: Int, staticParseSettings: ParserSettingsStatic) throws -> Bool {
        if staticParseSettings.dataSeparator == nil { throw ParserError.noDataSeparator }
        
        if staticParseSettings.hasData == false {return false}
        
        return true
    }
    
    private static func parse(line: String, withSeparator separator: Separator) throws -> [String] {
        var headerLine: [String] = []
        
        for nextComponent in line.components(separatedBy: separator.characterSet) {
            headerLine.append(nextComponent)
        }
        
        return headerLine
    }
    
    
    
    
    private static func indexInRange(_ index: Int, startRange: Int, endRange: Int) throws -> Bool{
        if startRange < endRange {throw ParserError.startingIndexHigherThanEndingIndex}
        
        if index >= startRange || index <= endRange {
            return true
        } else {
            return false
        }
    }
    
    
    private static func generateSimpleLineNumbers(withLines lines: [String]) -> String {
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
    
    
    enum ParserError: Error {
        case noParseSettings
        
        case startingIndexHigherThanEndingIndex
        
        case noExperimentalDetailsSeparator
        
        case noHeaderSeparator
        
        case noDataSeparator
        
        }
    
}
