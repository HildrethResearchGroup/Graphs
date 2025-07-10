//
//  StoredContent.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


struct StoredContent {
    let dataItemID: DataItem.ID?
    
    private let reducedNumberOfLines: Bool
    private(set) var content: String = ""
    private(set) var linesNumbers: String = ""
    private(set) var combinedLineNumbersAndContent: String = ""
    
    let date: Date = .now
    
    init(_ dataItemID: DataItem.ID?, url: URL?, parserSettings: ParserSettings?, _  reducedNumberOfLines: Bool) {
        self.dataItemID = dataItemID
        self.reducedNumberOfLines = reducedNumberOfLines
        
        self.setState(from: url, using: parserSettings)
    }
    

    
    private mutating func setState(from url: URL?, using parserSettings: ParserSettings?) {
        
        guard let url else {
            content = "Select File"
            linesNumbers = "0"
            combinedLineNumbersAndContent = linesNumbers + "\t" + content
            return
        }
        
        guard let parserSettings else {
            content = "Set Parser for File"
            linesNumbers = "0\n1"
            combinedLineNumbersAndContent = "0:\tString Encoding Needed.\n1:\tSet Parser for file."
            return
        }
        
        
        
        
        
        guard let localContent = try? Parser.content(for: url, using: parserSettings.parserSettingsStatic) else {
            content = "Could not decode file"
            linesNumbers = "0"
            combinedLineNumbersAndContent = linesNumbers + "\t" + content
            return
        }
        
        
        var lines = lines(from: localContent, using: parserSettings.newLineType)
        
        if reducedNumberOfLines {
            if lines.count >= 50 {
                lines = Array(lines[0..<50])
            }
        }
        
        
        let processedLines = processedLines(lines: lines)
        
        content = localContent
        linesNumbers = processedLines.lineNumbers
        combinedLineNumbersAndContent = processedLines.combinedLinesAndContent
    }
    
    
    private func lines(from input: String, using newLineType: NewLineType) -> [String] {
        
        let lineTypeLiteral = newLineType.stringLiteral
        
        let lines = input.components(separatedBy: lineTypeLiteral)
        
        return lines
    }
    
    
    private func processedLines(lines: [String]) -> (lineNumbers: String, combinedLinesAndContent: String) {
        let numberOfLines = lines.count
        
        let size = numberOfLines.size
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = size
        
        var lineNumbersOutput = ""
        var combinedLineNumbersAndContent = ""
        
        for (index, nextLine) in lines.enumerated() {
            let numberString = formatter.string(from: index + 1 as NSNumber) ?? ""
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
