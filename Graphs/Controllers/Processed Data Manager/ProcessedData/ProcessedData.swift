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
    
    var dataItem: DataItem
    
    var parsedFile: ParsedFile? {
        didSet {
            
        }
    }
    
    var graphController: GraphController?
    
    var lineNumbersVM: LineNumberViewModel
    
    var parsedFileState: TemplateState
    var graphTemplateState: TemplateState
    
    
    
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













