//
//  GraphController.swift
//  UsingDataGraphFramework
//
//  Created by Owen Hildreth on 12/21/21.
//

import Foundation
import SwiftUI

@Observable
class GraphController {
    
    var lastModified: Date = .now
        
    var dgController: DGController?
    
    
    // MARK: - Setup
    init(dgController: DGController?, data: [[String]]?) {
        self.dgController = dgController
        
        if let dgController {
            self.setDGController(withController: dgController, andData: data)
        }
    }
    
    
    
    
    
    func setDGController(withController dgController: DGController?, andData data: [[String]]?) {
        
        self.update(controller: dgController, withData: data)
        self.dgController = dgController
    }
    
    func updateGraphWithData(_ data: [[String]]) {
        self.update(controller: self.dgController, withData: data)
    }
    
    
    private func update(controller: DGController?, withData data: [[String]]?) {
        
        guard let controller else { return }
        
        guard let data else { return }
        
        if data.isEmpty { return }
        
        for (index, columnOfData) in data.enumerated() {
            guard  let dgColumn = controller.dataColumn(at: Int32(index + 1)) else {continue}
            
            dgColumn.setDataFrom(columnOfData)
            
        }
    }
    
    func clearGraph() {
        dgController = nil
    }
    
}

