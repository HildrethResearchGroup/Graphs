//
//  ProcessedData_Graph.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


extension ProcessedData {
    // MARK: - Caching Graphs
    func cacheDGController() {
        
        guard let dgController = graphController?.dgController else { return }
        
        let cm = CacheManager.shared
        
        cm.cacheDGController(dgController: dgController, for: dataItem)
    }
    
    
    func graphCacheState() -> CachedState {
        let cm = CacheManager()
        
        return cm.graphCacheState(for: dataItem)
    }
    
    
    
    // MARK: - Loading Graph
    func loadGraphController() {
        
        let cacheState = self.graphCacheState()
        
        if cacheState == .cachedStorageUpToDate {
            let dgController = self.cachedGraph()
                
            self.graphController = GraphController(dgController: dgController, data: nil)
        }
        
    }
}
