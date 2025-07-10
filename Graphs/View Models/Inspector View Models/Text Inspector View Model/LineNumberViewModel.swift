//
//  LineNumberProvider.swift
//  LineNumbers
//
//  Created by Owen Hildreth on 7/9/24.
//

import Foundation
import OSLog

@Observable
@MainActor
class LineNumberViewModel {
    
    var dataItem: DataItem?
    
    var parserSetting: ParserSettings? {
        dataItem?.getAssociatedParserSettings()
    }
    
    
    var url: URL? {
        dataItem?.url
    }
    
    var content: String
    var lineNumbers: String
    var combinedLineNumbersAndContent: String
    

    
    var newLineType: NewLineType? {
        get {
            parserSetting?.newLineType
        }
        set {
            guard let newValue else {return}
            parserSetting?.newLineType = newValue
        }
    }
    
    
    var stringEncodingType: StringEncodingType? {
        get {
            parserSetting?.stringEncodingType
        }
        set {
            guard let newValue else {return}
            parserSetting?.stringEncodingType = newValue
        }
    }
    
    
    // MARK: - Initialization
    init(_ dataItem: DataItem?) {
        self.dataItem = dataItem
        
        self.content = ""
        self.lineNumbers = ""
        self.combinedLineNumbersAndContent = ""
        
        self.registerForNotifications()
        
        self.updateState()
    }
    

    
    // MARK: - Notifications
    private func registerForNotifications() {
        let nc = NotificationCenter.default
        
        // TODO: Fix Swift 6 errors
        //nc.addObserver(self, selector: #selector(LineNumberViewModel.parserSettingsDidChange(_:)), name: .parserSettingPropertyDidChange, object: nil)
        
        //nc.addObserver(forName: .parserSettingPropertyDidChange, object: nil, queue: nil, using: parserSettingsDidChange(_:))
        
        nc.addObserver(self, selector: #selector(parserSettingsDidChange(_:)), name: .parserSettingPropertyDidChange, object: nil)
    }
    
    
    @objc private func parserSettingsDidChange(_ notification: Notification) {
        guard let settings = dataItem?.getAssociatedParserSettings() else {
            return
        }
        
        let info = notification.userInfo
        let key = Notification.Name.parserSettingPropertyDidChange
        
        guard let changedParserSettingsID: UUID = info?[key.rawValue] as? UUID else { return }
        
        if changedParserSettingsID == settings.localID {
            self.updateState()
        }
    }
    
    
    // MARK: - Updating State
    private func updateSettingsFromParser() {
        self.newLineType = .CRLF
        self.stringEncodingType = .ascii
    }
    
    
    func updateState() {
        
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
        
        guard let stringEncodingType = self.stringEncodingType else { return ""}
        
        let encoderType = stringEncodingType.encoding
        
        do {
            
            return try String(contentsOf: url, encoding: encoderType)
            
        } catch  {
            Logger.dataController.info("\(error)")
            return "Could not decode using: \(encoderType)"
        }
    }
    
    private func contentLines() -> [String] {
        
        guard let newLineType = self.newLineType else { return [""]}
        
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


extension LineNumberViewModel {
    func updateParserIsDisabled() -> Bool {
        if dataItem?.getAssociatedParserSettings() == nil {
            return true
        } else {
            return false
        }
    }
}
