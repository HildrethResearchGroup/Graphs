//
//  ProcessedData.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/27/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import OSLog

@Observable
class ProcessedData: Identifiable {
    
    // MARK: - Properties
    var id = UUID()
    
    var dataItem: DataItem
    
    var delegate: ProcessedDataDelegate?
    
    private(set) var parsedFile: ParsedFile?
    
    private(set) var graphController: GraphController?
    
    var parsedFileState: ProcessedDataState
    
    var graphTemplateState: ProcessedDataState
    
    
    // MARK: - Initialization
    init(dataItem: DataItem, delegate: ProcessedDataDelegate) async {
        self.dataItem = dataItem
        self.delegate = delegate
        
        // TODO: Set Processed Data State
        // Initialize values so actual state determining methods can be called
        parsedFileState = .outOfDate
        graphTemplateState = .outOfDate
        
        
        // TODO: Implement Caching
        // TODO: only load the graph controller when requested
        do {
            self.parsedFile = try await self.loadParsedFile()
            
            try await self.loadGraphController()
        } catch  {
            Logger.dataController.info("Could not generate graphController for: \(dataItem.name)")
        }
        
        parsedFileState = self.determineParsedFileState()
        graphTemplateState = await self.determineGraphControllerState()
        
        
    }
    
    
    // MARK: - Loading Graph
    
    func graphCacheState() -> CachedState {
        let cm = CacheManager()
        
        return cm.graphCacheState(for: dataItem)
    }
    
    
    func loadGraphController() async throws {
        
        let localState = await self.determineGraphControllerState()
        
        // Start with the immediately available states
        // Immediately available states must return value right away to avoid reparsing or regraphing system
        switch localState {
        case .noTemplate: return
        case .upToDate: return
        case .processing: return
        case .outOfDate: break
        case .notProcessed: break
        }
        
        // TODO: Implement Caching
        /*
         if self.graphCacheState() == .cachedStorageUpToDate {
         if let cachedGraph = delegate?.cachedGraph(for: dataItem) {
         self.graphController =  await GraphController(dgController: cachedGraph, data: nil)
         }
         }
         */
        
        let localParsedFile = try await self.loadParsedFile()
        
        guard let graphTemplate = dataItem.getAssociatedGraphTemplate() else {
            return
        }
        
        let localGraphController = await GraphController(from: graphTemplate.url, data: localParsedFile?.data)
        
        await localGraphController.setGraphTitle(graphTitle)
        
        self.graphController = localGraphController
    }
    
    
    private var graphTitle: String {
        return dataItem.name.replacingOccurrences(of: "_", with: "\\_")
    }
    

    // MARK: - State Determination
    @MainActor
    func updateParsedFileStates() {
        
        parsedFileState = determineParsedFileState()
        graphTemplateState = determineGraphControllerState()
    }
    
    
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
    
    
    @MainActor
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
        self.parsedFileState = .outOfDate
        
        Task {
            let localParsedFile = try? await self.loadParsedFile()
            _ = await MainActor.run {
                self.parsedFile = localParsedFile
                
            }
            try? await self.loadGraphController()
        }
    }
    
    
    
    func graphTemplateDidChange() {
        self.graphTemplateState = .outOfDate
        
        let newGraphTemplate = dataItem.getAssociatedGraphTemplate()
        
        guard let graphTemplateURL = newGraphTemplate?.url else {
            Task {
                await MainActor.run {
                    graphController?.setDGController(withController: nil, andData: nil)
                }
            }
            
            
            return
        }
        
        let newDGcontroller = DGController(contentsOfFile: graphTemplateURL.path(percentEncoded: false))
        
        Task {
            await MainActor.run {
                self.graphController?.setDGController(withController: newDGcontroller, andData: self.parsedFile?.data)
            }
        }
        
    }
    
}
