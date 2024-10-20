//
//  ProcessedDataDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/15/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


protocol ProcessedDataDelegate {
    
    func cacheGraphController(_ graphController: GraphController, for dataItem: DataItem)
    func cacheParsedFile(_ parsedFile: ParsedFile, for dataItem: DataItem)
    
    func cachedGraph(for dataItem: DataItem) -> DGController?
    
    func cachedParsedFile(for dataItem: DataItem) -> ParsedFile?
    
    func deleteCache(for dataItem: DataItem)
}
