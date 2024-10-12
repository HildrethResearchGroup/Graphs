//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

struct Parser {
    
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
    
    
    private static func lineIsExperimentalDetails(index: Int, parseSettings: ParserSettings) throws -> Bool {
        
        if parseSettings.experimentalDetailsSeparator == nil {throw ParserError.noExperimentalDetailsSeparator}
        
        if parseSettings.hasExperimentalDetails == false {return false }
        
        return try indexInRange(index, startRange: parseSettings.experimentalDetailsStart, endRange: parseSettings.experimentalDetailsStart)
    }
    
    private static func lineIsHeader(index: Int, parseSettings: ParserSettings) throws -> Bool {
        
        if parseSettings.headerSeparator == nil {throw ParserError.noHeaderSeparator}
        
        if parseSettings.hasHeader == false {return false}
        
        return try indexInRange(index, startRange: parseSettings.headerStart, endRange: parseSettings.headerEnd)
    }
    
    
    
    private static func lineIsData(index: Int, parseSettings: ParserSettings) throws -> Bool {
        if parseSettings.dataSeparator == nil { throw ParserError.noDataSeparator }
        
        if parseSettings.hasData == false {return false}
        
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
