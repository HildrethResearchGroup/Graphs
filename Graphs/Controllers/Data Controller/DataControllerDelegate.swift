//
//  DataControllerDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/25/24.
//

import Foundation

protocol DataControllerDelegate {
    func newData(nodes: [Node], andDataItems dataItems: [DataItem])
    
    
    func preparingToDelete(nodes: [Node])
    
    
    func preparingToDelete(dataItems: [DataItem])
    
    //func newParserSetting(parserSettings: ParserSettings)
    
    //func preparingToDelete(parserSettings: ParserSettings)
}
