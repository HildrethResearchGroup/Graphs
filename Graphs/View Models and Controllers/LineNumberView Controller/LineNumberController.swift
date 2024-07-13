//
//  LineNumberProvider.swift
//  LineNumbers
//
//  Created by Owen Hildreth on 7/9/24.
//

import Foundation

@Observable
class LineNumberController {
    
    var dataItem: DataItem? {
        didSet {
            updateSettingsFromParser()
            updateState()
        }
    }
    
    var url: URL? {
        dataItem?.url
    }
    
    var content: String
    var lineNumbers: String
    var combinedLineNumbersAndContent: String
    
    var newLineType: NewLineType {
        didSet {
            updateState()
        }
    }
    var stringEncodingType: StringEncodingType {
        didSet {
            updateState()
        }
    }
    
    
    init(_ dataItem: DataItem?) {
        self.dataItem = dataItem
        self.content = ""
        self.lineNumbers = ""
        self.combinedLineNumbersAndContent = ""
        
        if let parserSettings = dataItem?.parserSettings {
            self.newLineType = parserSettings.newLineType
            self.stringEncodingType = parserSettings.stringEncodingType
        } else {
            self.newLineType = .CRLF
            self.stringEncodingType = .ascii
        }
        self.updateState()
    }
    
    private func updateSettingsFromParser() {
        self.newLineType = .CRLF
        self.stringEncodingType = .ascii
    }
    
    
    private func updateState() {
        
        if dataItem == nil {
            content = ""
            lineNumbers = ""
        }
        
        Task {
            let localContent = getContent()
            let localLines = contentLines()
            
            let localNumbersString = await generateNumbersString(localLines)
            
            let localCombinedString = await generateCombinedNumbersAndLines(localLines)
            
            await MainActor.run {
                content = localContent
                lineNumbers = localNumbersString
                combinedLineNumbersAndContent = localCombinedString
            }
        }
    }
    
    
    
    private func getContent() -> String {
        
        guard let url else {return ""}
        
        let encoderType = stringEncodingType.encoding
        
        do {
            return try String(contentsOf: url, encoding: encoderType)
        } catch  {
            print(error)
            return "Could not decode using: \(encoderType.rawValue)"
        }
    }
    
    private func contentLines() -> [String] {
        let lineTypeLiteral = newLineType.stringLiteral
        
        let lines = content.components(separatedBy: lineTypeLiteral)
        
        return lines
    }
    
    
    
    private func generateNumbersString(_ lines: [String]) async -> String {
        
        let numberOfLines = lines.count
        
        let size = numberOfLines.size
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = size
        
        
        var localLineNumberString = ""
        
        
        
        for (index, _) in lines.enumerated() {
            let numberString = formatter.string(from: index + 1 as NSNumber) ?? ""
            
            if index == numberOfLines {
                localLineNumberString.append(numberString)
            } else {
                localLineNumberString.append(numberString + "\n")
            }
        }
        
        return localLineNumberString

    }
    
    private func generateCombinedNumbersAndLines(_ lines: [String]) async -> String {
        
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
    
    
    
}


extension LineNumberController {
    func updateParserSettings() {
        if let parserSettings = dataItem?.parserSettings {
            parserSettings.newLineType = self.newLineType
            parserSettings.stringEncodingType = self.stringEncodingType
        }
    }
    
    func updateParserIsDisabled() -> Bool {
        if dataItem?.parserSettings == nil {
            return true
        } else {
            return false
        }
    }
}
