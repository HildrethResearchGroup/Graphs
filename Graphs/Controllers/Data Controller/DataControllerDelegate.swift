//
//  DataControllerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/25/24.
//

import Foundation

protocol DataControllerDelegate {
    // MARK: - Filtering
    func filterDidChange(currentlySelectedDataItemIDs: [DataItem.ID])
    
    
    // MARK: - Nodes and DataItems
    func newObjects(nodes: [Node], dataItems: [DataItem], graphTemplates: [GraphTemplate], parserSettings: [ParserSettings])
    
    func preparingToDelete(nodes: [Node])
    
    func preparingToDelete(dataItems: [DataItem])
    
    
    //MARK: - ParserSettings
    func newParserSetting(_ parserSettings: ParserSettings)
    
    func preparingToDelete(parserSettings: ParserSettings)
    

    // MARK: - Graph Templates
    func newGraphTemplate(_ graphTemplate: GraphTemplate)
    
    func preparingToDelete(graphTemplate: GraphTemplate)
}



