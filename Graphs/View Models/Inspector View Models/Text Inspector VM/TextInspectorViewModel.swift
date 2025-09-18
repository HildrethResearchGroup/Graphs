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
    private var dataController: DataController
    
    private var processedDataManager: ProcessDataManager
    
    private var dataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    private var parserSettings: ParserSettings? {
        dataItem?.getAssociatedParserSettings()
    }
     
    
    // MARK: View State
    var textInspectorViewIsVisable: Bool = false {
        didSet {
            if textInspectorViewIsVisable {
                Task { await updateProcessedData() }
            }
        }
    }
    
    var parseInpsectorViewIsVisible: Bool = false {
        didSet {
            if parseInpsectorViewIsVisible {
                Task { await updateProcessedData() }
            }
        }
    }
    
    private var processedData: ProcessedData? {
        didSet {
            processingState = .upToDate
            lastModified = .now
        }
    }
    
    
    private var processingState: ProcessingState = .upToDate
    
    private var lastModified: Date = .now
    
    
    
    var content: String {
        if textInspectorViewIsVisable || parseInpsectorViewIsVisible {
            return processedData?.parsedFile?.content ?? ""
        } else {
            return "View is not visible"
        }
    }
    
    
    //var combinedLineNumbersAndContent: AttributedString {
    var combinedLineNumbersAndContent: String {
        if textInspectorViewIsVisable || parseInpsectorViewIsVisible {
            return processedData?.parsedFile?.combinedLineNumbersAndContent ?? ""
        } else {
            return "View is not visible"
        }
    }
    
    
    
    
    
    // MARK: - Initialization
    init(_ dataController: DataController, _ processedDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.processedDataManager = processedDataManager
        self.registerForNotifications()
        
        Task {
            await self.updateProcessedData()
        }
    }
    
    
    // MARK: - Updating State
    private func updateProcessedData() async {
        
        if !textInspectorViewIsVisable && !parseInpsectorViewIsVisible { return }
        
        guard let dataItem else {
            processedData = nil
            return
        }
        processingState = .inProgress
        processedData = await processedDataManager.processedData(for: dataItem)
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
        Task {
            
            await self.updateProcessedData()
        }
    }
}
