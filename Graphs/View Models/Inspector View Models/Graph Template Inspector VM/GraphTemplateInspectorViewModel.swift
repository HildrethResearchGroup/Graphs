//
//  GraphTemplateViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/17/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog


@Observable
@MainActor
class GraphTemplateInspectorViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var selection: GraphTemplate? {
        get { selectionManager.selectedGraphTemplate }
        set {
            
            selectionManager.selectedGraphTemplate = newValue
        }
    }
    
    var graphTemplates: [GraphTemplate] {
        self.dataController.graphTemplates
    }
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
    
}

extension GraphTemplateInspectorViewModel {
    func shouldAllowDrop(ofURLs urls: [URL]) -> Bool {
        if urls.count == 0 { return false }
        
        let allowedExtension = URL.dataGraphFileExtension
        
        for nextURL in urls {
            if nextURL.pathExtension != allowedExtension {
                return false
            }
        }
        
        return true
    }
    
    func importURLs(_ urls: [URL]) {
        _ = dataController.importURLs(urls, intoNode: nil)
    }
    
    func deleteSelectedGraphTemplate() {
        if let selectedGraphTemplate = selection {
            delete(graphTemplate: selectedGraphTemplate)
        }
    }
    
    func delete(graphTemplate: GraphTemplate) {
        dataController.delete(graphTemplate)
    }
    
    
    func duplicate(graphTemplate: GraphTemplate) {
        _ = dataController.duplicate(graphTemplate)
    }
}


// MARK: - View State
extension GraphTemplateInspectorViewModel {
    var filePath: String {
        guard let template = selection else { return "" }
        
        return template.url.path(percentEncoded: false)
    }
    
    func openInFinder() {
        guard let template = selection else { return }
        
        let url = template.url
        
        url.showInFinder()
    }
    
    var disableOpenButton: Bool {
        if selection == nil {
            return true
        } else {
            return false
        }
    }
}


// MARK: - UI Settings
extension GraphTemplateInspectorViewModel {
    func foregroundColor(for graphTemplate: GraphTemplate) -> Color {
        let selectedDataItems = dataController.selectedDataItems
        let graphTemplateID = graphTemplate.id
        
        for nextSelectedDataItem in selectedDataItems {
            let selectedDataItemGraphTemplate = nextSelectedDataItem.getAssociatedGraphTemplate()
            let id = selectedDataItemGraphTemplate?.id
            
            if id == graphTemplateID {
                return .green
            }
        }
        
        return .black
    }
}
