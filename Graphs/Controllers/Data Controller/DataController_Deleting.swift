//
//  DataController_Deleting.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/29/24.
//

import Foundation

// MARK: - Delete
extension DataController {
    
    func delete(_ nodes: [Node]) {
        // ADD
        delegate?.preparingToDelete(nodes: nodes)
        
        for nextNode in nodes {
            modelContext.delete(nextNode)
        }
        try? modelContext.save()
        
        fetchData()
    }
    
    func delete(_ dataItems: [DataItem]) {
        
        // ADD
        delegate?.preparingToDelete(dataItems: dataItems)
        
        for nextItem in dataItems {
            modelContext.delete(nextItem)
        }
        
        try? modelContext.save()
        
        fetchData()
    }
    
    func delete(_ dataItems: [DataItem], andThenTheNodes nodes: [Node]) {
        
        // It is important to delete the DataItems first so that the selection manager removes the data items from the selection.
        if dataItems.count > 0 {
            delete(dataItems)
            return
        }
        
        if nodes.count > 0 {
            delete(nodes)
            return
        }
    }
    
    func delete(_ parserSettings: ParserSettings) {
        modelContext.delete(parserSettings)
        try? modelContext.save()
        fetchData()
    }
    
    func delete(_ graphTemplate: GraphTemplate) {
        modelContext.delete(graphTemplate)
        try? modelContext.save()
        fetchData()
    }
}
