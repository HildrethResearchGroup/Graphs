//
//  Parser.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation

struct Parser {
    
    
    static func parse(_ url: URL, using staticSettings: ParserSettingsStatic, into id: UUID) async throws -> ParsedFile {
        
        try validateLineStartEndSettings(staticSettings)
        
        var content = try content(for: url, using: staticSettings)
        
        if staticSettings.newLineType == .auto {
            
            content = content.replacingOccurrences(of: "\r", with: "")
            
        }
        
        let lineSeparator = staticSettings.newLineType.stringLiteral
        
        let lines: [String] = content.components(separatedBy: lineSeparator)
        
        var parsedFile = ParsedFile(dataItemID: id)
        
        //var header: [[String]] = []
        //var data: [DataColumn] = []
        
        //var footer = ""
        
        
        var index = 1
        
        for  nextLine in lines {
            let type = staticSettings.parseLineType(for: index)
            
            switch type {
            case .skip: break
            case .error: break
                //print("Error during parsing at index: \(index).  For line:\n\(nextLine)")
            case .experimentalDetails:
                if index == staticSettings.experimentalDetailsStart {
                    parsedFile.experimentDetails.append(nextLine)
                } else {
                    parsedFile.experimentDetails.append("\n")
                    parsedFile.experimentDetails.append(nextLine)
                }
            case .header:
                let separator = staticSettings.headerSeparator
                
                if separator == .none { throw ParserError.noHeaderSeparator }
                
                let nextheaderLine = parse(line: nextLine, withSeparator: separator)
                parsedFile.header.append(nextheaderLine)
            case .data:
                
                if staticSettings.stopDataAtFirstEmptyLine && nextLine.isEmpty {
                    break
                }
                
                let separator = staticSettings.dataSeparator
                if separator == .none { throw ParserError.noDataSeparator }
                let nextDataLine = parse(line: nextLine, withSeparator: separator)
                
                if staticSettings.stopDataAtFirstEmptyLine {
                    if nextDataLine.allAreEmpty() {
                        break
                    }
                }
                
                
                parsedFile.appendRow(nextDataLine)
               
            case .end:
                break
            }
            
            index += 1
        }
        
      
        return parsedFile
        
        /*
         return ParsedFile(dataItemID: id,
                           experimentDetails: experimentalDetails,
                           header: header,
                           data: transposedData,
                           footer: footer,
                           numberOfColumns: numberOfColumns)
         */
    }
   
    
    private static func validateLineStartEndSettings(_ settings: ParserSettingsStatic) throws {
        if settings.hasExperimentalDetails {
            if settings.experimentalDetailsStart < 0 {
                throw ParserError.indexBelowZero
            } else if settings.experimentalDetailsEnd < settings.experimentalDetailsStart {
                throw ParserError.startingIndexHigherThanEndingIndex
            }
        }
        
        if settings.hasHeader {
            if settings.headerStart <= settings.experimentalDetailsEnd {
                throw ParserError.startingIndexHigherThanEndingIndex
            } else if settings.headerEnd < settings.headerStart {
                throw ParserError.startingIndexHigherThanEndingIndex
            }
        }
        
        if settings.hasData {
            if settings.dataStart <= settings.headerEnd {
                throw ParserError.startingIndexHigherThanEndingIndex
            }
        }
    
    }
    
    
    static func content(for url: URL, using staticSettings: ParserSettingsStatic) throws -> String {
        let encoding = staticSettings.stringEncodingType.encoding
        
        
        // Automatically determine string encoding type
        if staticSettings.stringEncodingType == .automatic {
            
            var encodingDetermined = false
            
            var determinedEncoding: String.Encoding = .utf8
            
            // Try initial automatic determination with utf8
            if let localContent = try? String(contentsOf: url, usedEncoding: &determinedEncoding) {
                print("Determined Encoding = \(determinedEncoding)")
                encodingDetermined = true
                // String was able to determine encoding type and decode the url
                return localContent
            }
            
            // Try again with Windows default
            if encodingDetermined == false {
                determinedEncoding = .windowsCP1250
                
                if let localContent = try? String(contentsOf: url, usedEncoding: &determinedEncoding) {
                    print("Determined Encoding = \(determinedEncoding)")
                    encodingDetermined = true
                    // String was able to determine encoding type and decode the url
                    return localContent
                }
                
            }
            
            // utf8 and Windows default didn't work, try one more time with ascii
            if encodingDetermined == false {
                guard let defaultContent = try? String(contentsOf: url, encoding: .windowsCP1250) else {
                    print("Could not get string of type: \(encoding)\n At url: \(url)")
                    throw ParserError.couldNotGetStringFromURL
                }
                return defaultContent
            }
            
        } else { // String encoding type was explicitly set by the user
            
            guard let explicitContent = try? String(contentsOf: url, encoding: encoding) else {
                print("Could not get string of type: \(encoding)\n At url: \(url)")
                throw ParserError.couldNotGetStringFromURL
            }
            return explicitContent
        }
    }
    
    
    
    
    
    private static func parse(line: String, withSeparator separator: Separator) -> [String] {
        var headerLine: [String] = []
        
        if separator == .none {
            return [line]
        }
        
        guard let separatorCharacterSet = separator.characterSet else {
            return [line]
        }
        
        for nextComponent in line.components(separatedBy: separatorCharacterSet) {
            headerLine.append(nextComponent)
        }
        
        return headerLine
    }
    
    
    
    
    private static func indexInRange(_ index: Int, startRange: Int, endRange: Int) throws -> Bool{
        if startRange > endRange {throw ParserError.startingIndexHigherThanEndingIndex}
        
        if index >= startRange - 1 && index <= endRange - 1 {
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
    
    
    // From: https://stackoverflow.com/questions/45412684/how-to-transpose-a-matrix-of-unequal-array-length-in-swift-3
    private static func transpose<Element>(_ input: [[Element]], defaultValue: Element) -> [[Element]] {
        let columns = input.count
        let rows = input.reduce(0) { max($0, $1.count) }

        return (0 ..< rows).reduce(into: []) { result, row in
            result.append((0 ..< columns).reduce(into: []) { result, column in
                result.append(row < input[column].count ? input[column][row] : defaultValue)
            })
        }
    }
    
    
    
    enum ParserError: Error {
        case noParseSettings
        
        case indexBelowZero
        
        case startingIndexHigherThanEndingIndex
        
        case separatorIsNone
        
        case noExperimentalDetailsSeparator
        
        case noHeaderSeparator
        
        case noDataSeparator
        
        case couldNotGetStringFromURL
        
        }
    
}



// MARK: - Unused

/*
 // Experimental Details
 if try lineIsExperimentalDetails(index: index, staticParseSettings: staticSettings) {
     experimentalDetails.append("\n")
     experimentalDetails.append(nextLine)
 }
 // Header
 else if try lineIsHeader(index: index, staticParseSettings: staticSettings) {
     
     let separator = staticSettings.headerSeparator
     
     if separator == .none { throw ParserError.noHeaderSeparator }
     
     let nextheaderLine = parse(line: nextLine, withSeparator: separator)
     header.append(nextheaderLine)
 }
 // Data
 else if try lineIsData(index: index, staticParseSettings: staticSettings) {
     
     let separator = staticSettings.dataSeparator
     
     if separator == .none { throw ParserError.noDataSeparator }
     
     let nextDataLine = parse(line: nextLine, withSeparator: separator)
     data.append(nextDataLine)
 }
 // Footer
 else {
     footer.append("\n")
     footer.append(nextLine)
 }
 */


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


/*
 private static func lineIsExperimentalDetails(index: Int, staticParseSettings: ParserSettingsStatic) throws -> Bool {
     
     //if staticParseSettings.experimentalDetailsSeparator == .none { return false }
     
     if staticParseSettings.hasExperimentalDetails == false { return false }
     
     let isInRange = try indexInRange(index, startRange: staticParseSettings.experimentalDetailsStart, endRange: staticParseSettings.experimentalDetailsStart)
     
     return isInRange
 }
 
 private static func lineIsHeader(index: Int, staticParseSettings : ParserSettingsStatic) throws -> Bool {
     
     //if staticParseSettings.headerSeparator == .none {throw ParserError.noHeaderSeparator}
     
     if staticParseSettings.hasHeader == false {return false}
     
     return try indexInRange(index, startRange: staticParseSettings.headerStart, endRange: staticParseSettings.headerEnd)
 }
 
 
 
 private static func lineIsData(index: Int, staticParseSettings: ParserSettingsStatic) throws -> Bool {
     
     return staticParseSettings.hasData
 }
 */
