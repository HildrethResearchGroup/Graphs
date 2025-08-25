//
//  DataController_Deleting.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/29/24.
//

import Foundation

// MARK: - Delete
extension DataController {
    
    func delete(_ nodeIDs: [Node.ID]) {
        var nodesToDelete: [Node] = []
        
        for nextNode in allNodes() {
            if nodeIDs.contains(where: { $0 == nextNode.id}) {
                nodesToDelete.append(nextNode)
            }
        }
        
        delete(nodesToDelete)
    }
    
    func delete(_ nodes: [Node]) {
        // ADD
        
        if nodes.isEmpty { return }
            
        delegate?.preparingToDelete(nodes: nodes)
        
        for nextNode in nodes {
            modelContext.delete(nextNode)
        }
        try? modelContext.save()
        
        fetchAllObjects()
    }
    
    private func delete(_ dataItems: [DataItem]) {
        if dataItems.isEmpty { return }
        
        // ADD
        delegate?.preparingToDelete(dataItems: dataItems)
        
        for nextItem in dataItems {
            modelContext.delete(nextItem)
        }
        
        try? modelContext.save()
        
        
    }
    
    func delete(_ dataItems: [DataItem], andThenNodes nodes: [Node]) {
        
        // It is important to delete the DataItems first so that the selection manager removes the data items from the selection.
        if dataItems.count > 0 {
            delete(dataItems)
        }
        
        if nodes.count > 0 {
            delete(nodes)
        }
        
        fetchAllObjects()
    }
    
    func delete(_ parserSettings: ParserSettings) {
        
        delegate?.preparingToDelete(parserSettings: parserSettings)
        
        modelContext.delete(parserSettings)
        try? modelContext.save()
        //fetchAllObjects()
    }
    
    func delete(_ graphTemplate: GraphTemplate) {
        
        delegate?.preparingToDelete(graphTemplate: graphTemplate)
        
        modelContext.delete(graphTemplate)
        try? modelContext.save()
        fetchAllObjects()
    }
}
