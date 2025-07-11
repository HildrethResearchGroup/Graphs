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
    var viewIsVisable: Bool = false
    
    var processingState: ProcessingState = .upToDate
    
    var reducedNumberOfLines = true
    
    var newLineType: NewLineType {
        get { parserSettings?.newLineType ?? .CRLF }
        set {
            let oldValue = newLineType
            
            if newValue != parserSettings?.newLineType {
                parserSettings?.newLineType = newValue
            }
            
            if newValue != oldValue {
                processingState = .outOfDate
                updateStoredContent()
            }
        }
    }
    
    
    var stringEncodingType: StringEncodingType {
        get { parserSettings?.stringEncodingType ?? .ascii }
        set {
            let oldValue = stringEncodingType
            
            if newValue != parserSettings?.stringEncodingType {
                parserSettings?.stringEncodingType = newValue
            }
            
            if newValue != oldValue {
                processingState = .outOfDate
                updateStoredContent()
            }
        }
    }
    
    
    
    
    var content: String {
        updateStoredContent()
        return storedContent.content
    }
    
    //var combinedLineNumbersAndContent: AttributedString {
    var combinedLineNumbersAndContent: String {
        updateStoredContent()
        return storedContent.combinedLineNumbersAndContent
    }
    
    
    private var storedContent: StoredContent
    
    
    
    // MARK: - Initialization
    init(_ dataController: DataController) {
        self.dataController = dataController
        self.storedContent = StoredContent(nil, url: nil, parserSettings: nil, false)
        
        self.updateStoredContent()
        self.registerForNotifications()
    }
    
    
    // MARK: - Updating State
    private func updateStoredContent() {
        
        if viewIsVisable == false { return }
        
        
        // Sendable dataItem information
        let url = dataItem?.url
        let dataItemID = dataItem?.id
        let parserSettings = dataItem?.getAssociatedParserSettings()?.parserSettingsStatic
        let parserSettingsDateLastModified = parserSettings?.lastModified
        
        // Sendable storedContent information
        let storedContentDataID = storedContent.dataItemID
        let storedContentLastMofified = storedContent.date
        
        switch processingState {
        case .none: break
        case .outOfDate: break
        case .inProgress:
            if dataItemID == storedContentDataID { return }
        case .upToDate:
            if dataItemID == storedContentDataID { return }
        }
        
        
        
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
}


// MARK: - Notifications
extension TextInspectorViewModel {
    fileprivate func registerForNotifications() {
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
                       selector: #selector(selectedDataItemDidChange(_:)),
                       name: .selectedDataItemDidChange,
                       object: nil)
    }
    
    @objc func selectedDataItemDidChange(_ notification: Notification) {
        self.processingState = .outOfDate
        
        self.updateStoredContent()
    }
}
