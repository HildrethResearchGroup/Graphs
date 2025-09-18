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
    var viewIsVisable: Bool = false {
        didSet {
            if viewIsVisable {
                Task { await updateProcessedData() }
            }
        }
    }
    
    private var processedData: ProcessedData? {
        didSet {
            lastModified = .now
        }
    }
    
    
    private var processingState: ProcessingState = .upToDate
    
    private var lastModified: Date = .now
    
    
    
    var content: String {
        if viewIsVisable {
            return processedData?.parsedFile?.content ?? ""
        } else {
            return ""
        }
    }
    
    
    //var combinedLineNumbersAndContent: AttributedString {
    var combinedLineNumbersAndContent: String {
        if viewIsVisable {
            return processedData?.parsedFile?.combinedLineNumbersAndContent ?? ""
        } else {
            return ""
        }
    }
    
    
    
    
    
    // MARK: - Initialization
    init(_ dataController: DataController, _ processedDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.processedDataManager = processedDataManager
        
        Task {
            await self.updateProcessedData()
            self.registerForNotifications()
        }
    }
    
    
    // MARK: - Updating State
    private func updateProcessedData() async {
        
        if viewIsVisable == false { return }
        
        guard let dataItem else {
            processedData = nil
            return
        }
        
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
