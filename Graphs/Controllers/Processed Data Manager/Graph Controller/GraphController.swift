//
//  GraphController.swift
//  UsingDataGraphFramework
//
//  Created by Owen Hildreth on 12/21/21.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class GraphController {
    
    var lastModified: Date = .now
        
    var dgController: DGController?
    
    // MARK: - Setup
    init(dgController: DGController?, data: [DataColumn]?) {
        self.dgController = dgController
        
        if let dgController {
            self.setDGController(withController: dgController, andData: data)
        }
        
    }
    
    
    convenience init(from url: URL, data: [DataColumn]?) {
        
        let localDGController = DGController(contentsOfFile: url.path(percentEncoded: false))
        
        self.init(dgController: localDGController, data: data)
    }
    
    
    
    func setDGController(withController dgController: DGController?, andData data: [DataColumn]?) {
        
        self.update(controller: dgController, withData: data)
        self.dgController = dgController
    }
    
    func updateGraphWithData(_ data: [DataColumn]) {
        
        self.update(controller: self.dgController, withData: data)
    }
    
    
    private func update(controller: DGController?, withData data: [DataColumn]?) {
        
        guard let controller else { return }
        
        guard let data else { return }
        
        if data.isEmpty { return }
        
        for (index, columnOfData) in data.enumerated() {
            
            let numberOfGraphTemplateColumns = controller.dataColumns().count
            
            if index + 1 >= numberOfGraphTemplateColumns { break }
            
            guard  let dgColumn = controller.dataColumn(at: Int32(index + 1)) else {continue}
            
            dgColumn.setDataWith(columnOfData)
        }
    }
    
    func clearGraph() {
        dgController = nil
    }
    
    
    func aspectRatio() -> CGFloat {
        var ratio = 1.3
        
        guard let controller = dgController else { return ratio }
        
        guard let sizeString = controller.canvasSettings().sizeString() else { return ratio }
        
        let filterSize = sizeString.filter({ "01234567890.,".contains($0)} )
        
        let sizes = filterSize.components(separatedBy: ",")
        
        if sizes.count == 2 {
            guard let width = Double(sizes[0]) else { return ratio }
            guard let height = Double(sizes[1]) else { return ratio }
            
            ratio = width / height
                        
        }
        
        return ratio
    }
}

