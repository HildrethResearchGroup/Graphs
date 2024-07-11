//
//  LineNumberProvider.swift
//  LineNumbers
//
//  Created by Owen Hildreth on 7/9/24.
//

import Foundation

@Observable
class LineNumberProvider {
    
    var dataItem: DataItem? {
        didSet {
            updateState()
        }
    }
    
    var url: URL? {
        dataItem?.url
    }
    
    var content: String
    var lineNumbers: String
    
    init(_ dataItem: DataItem?) {
        self.dataItem = dataItem
        self.content = ""
        self.lineNumbers = ""
        
        self.updateState()
    }
    
    private func updateState() {
        
        if dataItem == nil {
            content = ""
            lineNumbers = ""
        }
        
        Task {
            let localContent = getContent()
            let localNumbersString = await generateNumbers()
            
            await MainActor.run {
                content = localContent
                lineNumbers = localNumbersString
            }
        }
    }
    
    private func getContent() -> String {
        
        guard let url else {return ""}
        
        if let encoding = dataItem?.parserSettings?.stringEncodingType.encoding {
            do {
                return try String(contentsOf: url, encoding: encoding)
            } catch  {
                print(error)
                return "Could not decode using: \(encoding.rawValue)"
            }
        } else {
            do {
                return try String(contentsOf: url, encoding: .ascii)
            } catch  {
                print(error)
                return "No Encoding Set in Parser.  Could not decode using default .ascii type.  Make a Parser is Set for the file/folder and set the string encoding to the correct type"
            }
        }
    }
    
    
    private func generateNumbers() async -> String {
        
        do {
            let lineCount = try await numberOfLines()
            let size = lineCount.size
            
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = size
            
            
            var localLineNumberString = ""
            
            for nextIndex in 0..<lineCount {
                let numberString = formatter.string(from: nextIndex + 1 as NSNumber) ?? ""
                
                if nextIndex == lineCount {
                    localLineNumberString.append(numberString)
                } else {
                    localLineNumberString.append(numberString + "\n")
                }
            }
            
            return localLineNumberString
            
        } catch  {
            print(error)
            return "0"
        }
    }
    
    
    private func numberOfLines() async throws -> Int {
        var output = 0
        
        guard let url else {return output}
        
        for try await _ in url.lines {
            output += 1
        }
        
        return output
    }
}


