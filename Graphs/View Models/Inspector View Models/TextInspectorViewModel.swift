//
//  TextInspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/8/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


@Observable
@MainActor
class TextInspectorViewModel {
    // MARK: Data Sources
    var dataController: DataController
    
    var dataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    var parserSettings: ParserSettings? {
        dataItem?.getAssociatedParserSettings()
    }
    
    
    // MARK: View State
    var viewIsVisiable: Bool = false
    
    var processingState: TextInspectorViewModel.ProcessingState = .upToDate {
        didSet {
            print("processingState = \(processingState)")
        }
    }
    
    var reducedNumberOfLines = true
    
    var newLineType: NewLineType {
        get { parserSettings?.newLineType ?? .CRLF }
        set {
            
            if newValue != parserSettings?.newLineType {
                parserSettings?.newLineType = newValue
            }
            
            if newValue != newLineType {
                updateStoredContent()
            }
        }
    }
    
    
    var stringEncodingType: StringEncodingType {
        get { parserSettings?.stringEncodingType ?? .ascii }
        set {
            
            if newValue != parserSettings?.stringEncodingType {
                parserSettings?.stringEncodingType = newValue
            }
            
            if newValue != stringEncodingType {
                updateStoredContent()
            }
        }
    }
    
    
    
    
    var content: String {
        updateStoredContent()
        return storedContent.content
    }
    
    var combinedLineNumbersAndContent: String {
        updateStoredContent()
        return storedContent.combinedLineNumbersAndContent
    }
    
    
    private var storedContent: StoredContent
    
    
    init(_ dataController: DataController) {
        self.dataController = dataController
        self.storedContent = StoredContent(nil, url: nil, parserSettings: nil, false)
        
        self.updateStoredContent()
    }
    
    
    // MARK: - Updating State
    private func updateStoredContent() {
        
        if viewIsVisiable == false { return }
        
        // Sendable dataItem information
        let url = dataItem?.url
        let dataItemID = dataItem?.id
        let parserSettings = dataItem?.getAssociatedParserSettings()
        let parserSettingsDateLastModified = parserSettings?.lastModified
        
        // Sendable storedContent information
        let storedContentDataID = storedContent.dataItemID
        let storedContentLastMofified = storedContent.date
        
        Task {
            
            // IDs don't match, need to update the storedContent
            // A nil dataItem will be handled by the StoredContent parsing
            if storedContentDataID != dataItemID {
                self.processingState = .inProgress
                storedContent = StoredContent(dataItemID, url: url, parserSettings: parserSettings, reducedNumberOfLines)
                self.processingState = .upToDate
                return
            }
            
            
            // Check to see if the parserSettings have changed
            if let lastModified = parserSettingsDateLastModified {
                if lastModified > storedContentLastMofified {
                    self.processingState = .inProgress
                    storedContent = StoredContent(dataItemID, url: url, parserSettings: parserSettings, reducedNumberOfLines)
                    self.processingState = .upToDate
                    return
                }
            }
        }
    }
    
    
    private struct StoredContent {
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
                if lines.count <= 50 {
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
    
    enum ProcessingState {
        case upToDate
        case inProgress
    }
    
}
