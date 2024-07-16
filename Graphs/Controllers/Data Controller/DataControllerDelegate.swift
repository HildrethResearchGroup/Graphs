//
//  DataControllerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/25/24.
//

import Foundation

protocol DataControllerDelegate {
    
    // MARK: - Nodes and DataItems
    func newData(nodes: [Node], andDataItems dataItems: [DataItem])
    
    func preparingToDelete(nodes: [Node])
    
    func preparingToDelete(dataItems: [DataItem])
    
    
    //MARK: - ParserSettings
    func newParserSetting(parserSettings: ParserSettings)
    
    func preparingToDelete(parserSettings: ParserSettings)
    

    // MARK: - Graph Templates
    func newGraphTemplate(graphTemplate: GraphTemplate)
    
    func preparingToDeleteGraphTemplate(graphTemplate: GraphTemplate)
}



