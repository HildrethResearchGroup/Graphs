//
//  StoredContent.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftUI


struct StoredContent {
    let dataItemID: DataItem.ID?
    
    private let reducedNumberOfLines: Bool
    private(set) var content: String = ""
    private(set) var linesNumbers = ""
    //private(set) var combinedLineNumbersAndContent: AttributedString = ""
    private(set) var combinedLineNumbersAndContent = ""
    
    let date: Date = .now
    
    init(_ dataItemID: DataItem.ID?, url: URL?, parserSettings: ParserSettingsStatic?, _  reducedNumberOfLines: Bool) {
        self.dataItemID = dataItemID
        self.reducedNumberOfLines = reducedNumberOfLines
        
        self.setState(from: url, using: parserSettings)
    }
    

    
    private mutating func setState(from url: URL?, using parserSettings: ParserSettingsStatic?) {
        
        guard let url else {
            content = "Select File"
            linesNumbers = "0"
            //combinedLineNumbersAndContent = AttributedString(linesNumbers + "\t" + content)
            combinedLineNumbersAndContent = linesNumbers + "\t" + content
            return
        }
        
        guard let parserSettings else {
            content = "Set Parser for File"
            linesNumbers = "0\n1"
            combinedLineNumbersAndContent = "0:\tString Encoding Needed.\n1:\tSet Parser for file."
            return
        }
        
        
        
        
        guard let localContent = try? Parser.content(for: url, using: parserSettings) else {
            content = "Could not decode file"
            linesNumbers = "0"
            //combinedLineNumbersAndContent = AttributedString(linesNumbers + "\t" + content)
            combinedLineNumbersAndContent = linesNumbers + "\t" + content
            return
        }
        
        
        var lines = lines(from: localContent, using: parserSettings.newLineType)
        
        if reducedNumberOfLines {
            if lines.count >= 50 {
                lines = Array(lines[0..<50])
            }
        }
        
        
        let processedLines = processedLines(lines: lines, using: parserSettings)
        
        content = localContent
        linesNumbers = processedLines.lineNumbers
        combinedLineNumbersAndContent = processedLines.combinedLinesAndContent
    }
    
    
    private func lines(from input: String, using newLineType: NewLineType) -> [String] {
        
        let lineTypeLiteral = newLineType.stringLiteral
        
        let lines = input.components(separatedBy: lineTypeLiteral)
        
        return lines
    }
    
    
    //private func processedLines(lines: [String], using parserSettings: ParserSettingsStatic) -> (lineNumbers: String, combinedLinesAndContent: AttributedString) {
    private func processedLines(lines: [String], using parserSettings: ParserSettingsStatic) -> (lineNumbers: String, combinedLinesAndContent: String) {
        
        /*
         let useStringColors: Bool
         
         do {
             useStringColors = try parserSettings.validateLineStartEndSettings()
         } catch  {
             useStringColors = false
         }
         
         var color: Color = .black
         */
        
        
        let numberOfLines = lines.count
        
        let size = numberOfLines.size
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = size
        
        var lineNumbersOutput:String = ""
        //var combinedLineNumbersAndContent: AttributedString = ""
        var combinedLineNumbersAndContent = ""
        
        for (index, nextLine) in lines.enumerated() {
            
            /*
             if useStringColors {
                 let lineType = parserSettings.parseLineType(for: index)
                 color = lineType.color
             }
             */
            
            
            
            let numberString = formatter.string(from: index + 1 as NSNumber) ?? ""
            
            
            //var nextString:AttributedString = AttributedString(numberString + "\t" + nextLine)
            //nextString.foregroundColor = color
            //let nextString:AttributedString = numberString + "\t" + nextLine
            let nextString = numberString + "\t" + nextLine
            
            if index == numberOfLines {
                lineNumbersOutput.append(numberString)
                combinedLineNumbersAndContent.append(nextString)
            } else {
                lineNumbersOutput.append(numberString + "\n")
                combinedLineNumbersAndContent.append(nextString + "\n")
            }
            
        }
        
        return (lineNumbersOutput, combinedLineNumbersAndContent)
        
    }
}
