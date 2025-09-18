//
//  InspectorViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/17/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class InspectorViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    private var processDataManager: ProcessDataManager
    
    var parserSettingsVM: ParserSettingsViewModel
    
    var graphTemplateInspectorVM: GraphTemplateInspectorViewModel
    
    var dataItemsVM: DataItemsInspectorViewModel
    
    var nodeInspectorVM: NodeInspectorViewModel
    
    var textInspectorVM: TextInspectorViewModel
    
    var tableInspectorVM: TableInspectorViewModel
    
    
    var firstDataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    
    private init(_ dataController: DataController, _ selectionManager: SelectionManager, _ processDataManager: ProcessDataManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        self.processDataManager = processDataManager
        
        self.parserSettingsVM = ParserSettingsViewModel(dataController, selectionManager)
        
        self.graphTemplateInspectorVM = GraphTemplateInspectorViewModel(dataController, selectionManager)
        
        self.dataItemsVM = DataItemsInspectorViewModel(dataController, selectionManager)
        
        self.nodeInspectorVM = NodeInspectorViewModel(dataController, selectionManager)
        
        self.textInspectorVM = TextInspectorViewModel(dataController, processDataManager)
        
        self.tableInspectorVM = TableInspectorViewModel(dataController, processDataManager)
        
    }
    
    
    convenience init(_ commonManagers: AppController.CommonManagers) {
        let cm = commonManagers
        
        self.init(cm.dataController, cm.selectionManager, cm.processedDataManager)
    }
}

// MARK: - Tool Tips
extension InspectorViewModel {
    private var selectedNodesCount: Int { selectionManager.selectedNodeIDs.count }
    private var selectedDataItemscount: Int { selectionManager.selectedDataItemIDs.count }
    
    
    var toolTip_Node: String {
        let defaultTip = "Edit Folder Properties"
        switch selectedNodesCount {
        case 0: return defaultTip
        case 1:
            guard let node = dataController.selectedNodes.first else {
                return defaultTip
            }
            return "Edit \(node.name) Folder Properties"
        default: return defaultTip
            
        }
    }
    
    var toolTip_DataItem: String {
        let defaultTip = "Edit Data Properties"
        switch selectedDataItemscount {
        case 0: return defaultTip
        case 1:
            guard let dataItem = dataController.selectedDataItems.first else {
                return defaultTip
            }
            return "Edit \(dataItem.name) Data Properties"
        default: return defaultTip
            
        }
    }
    
    
    var toolTip_GraphTemplate: String {
        return "Import and edit the DataGraph files used to graph your data"
    }
    
    var toolTip_ParserSettings: String {
        return "Create and edit data Parsers"
    }
    
    var toolTip_TextInspector: String {
        return "View your data as text.  Note: nothing will appear if the data doesn't have a Parser with the proper string encoding set."
    }
    
    var toolTip_TableInspector: String {
        return "View your parsed data in a table.  Note: nothing will appear if the Data doesn't have a Parser with the proper settings."
    }
}
