//
//  ProcessedData.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/27/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

@Observable
class ProcessedData {
    
    // MARK: - Properties
    var dataItem: DataItem
    
    var delegate: ProcessedDataDelegate?
    
    private(set) var parsedFile: ParsedFile?
    
    var graphController: GraphController?
    
    var lineNumbersVM: LineNumberViewModel
    
    var parsedFileState: ProcessedDataState
    var graphTemplateState: ProcessedDataState
    
    
    
    // MARK: - Initialization
    init(dataItem: DataItem, delegate: ProcessedDataDelegate) async {
        self.dataItem = dataItem
        self.delegate = delegate
        
        self.lineNumbersVM = LineNumberViewModel(dataItem)
        
        
        // TODO: Implement data caching
        
        let url = dataItem.url
        if let staticSettings = dataItem.getAssociatedParserSettings()?.parserSettingsStatic {
            let id = dataItem.localID
            
            
            do {
                parsedFile = try await Parser.parse(url, using: staticSettings, into: id)
            } catch  {
                print("ERROR during processedData initializer parsing file")
                print(error)
                parsedFile = nil
            }
        } else {
            parsedFile = nil
        }
        
        
        // TODO: Set Processed Data State
        // Initialize values so actual state determining methods can be called
        parsedFileState = .outOfDate
        graphTemplateState = .outOfDate
        
        
        parsedFileState = self.determineParsedFileState()
        graphTemplateState = self.determineGraphControllerState()
    }
    
    
    
    // MARK: - State Determination
    func determineParsedFileState() -> ProcessedDataState {
        guard let parsedSettings = dataItem.getAssociatedParserSettings() else {
            return .noTemplate
        }
        
        let settingsDate = parsedSettings.lastModified
        
        guard let parsedFile else {
            return .notProcessed
        }
        
        if parsedFile.lastParsedDate < settingsDate {
            return .outOfDate
        }
        
        return .upToDate
    }
    
    
    func determineGraphControllerState() -> ProcessedDataState {
        guard let graphTemplate = dataItem.getAssociatedGraphTemplate() else {
            return .noTemplate
        }
        
        guard let graphController else {
            return .notProcessed
        }
        
        guard let templateDate = graphTemplate.url.dateLastModified else {
            return .noTemplate
        }
        
        if graphController.lastModified < templateDate {
            return .outOfDate
        }
        
        return .upToDate
    }
    
    
    
    // MARK: - Handling Changes
    func parserDidChange() {
        
        let url = dataItem.url
        guard let staticSettings = dataItem.getAssociatedParserSettings()?.parserSettingsStatic else {
            return
        }
        let id = dataItem.localID
        
        Task {
            let newParsedFile = try? await Parser.parse(url, using: staticSettings, into: id)
            
            await MainActor.run {
                parsedFile = newParsedFile
                
                let data = newParsedFile?.data ?? [[]]
                
                graphController?.updateGraphWithData(data)
                
            }
        }
    }

    
    func graphTemplateDidChange() {
        let newGraphTemplate = dataItem.getAssociatedGraphTemplate()
        
        guard let graphTemplateURL = newGraphTemplate?.url else {
            graphController?.setDGController(withController: nil, andData: nil)
            return
        }
        
        let newDGcontroller = DGController(contentsOfFile: graphTemplateURL.path())
        
        self.graphController?.setDGController(withController: newDGcontroller, andData: self.parsedFile?.data)
    }

    
}
