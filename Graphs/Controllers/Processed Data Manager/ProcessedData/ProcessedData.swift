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
    
    private(set) var parsedFile: ParsedFile?
    
    var graphController: GraphController?
    
    var lineNumbersVM: LineNumberViewModel
    
    var parsedFileState: ProcessedDataState
    var graphTemplateState: ProcessedDataState
    
    
    
    // MARK: - Initialization
    init(dataItem: DataItem) async {
        self.dataItem = dataItem
        self.lineNumbersVM = LineNumberViewModel(dataItem)
        
        
        // TODO: Implement data caching
        
        do {
            parsedFile = try await Parser.parseDataItem(dataItem)
        } catch  {
            print("ERROR during processedData initializer parsing file")
            print(error)
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
    private func determineParsedFileState() -> ProcessedDataState {
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
    
    
    private func determineGraphControllerState() -> ProcessedDataState {
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
        Task {
            let newParsedFile = try? await Parser.parseDataItem(dataItem)
            
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













