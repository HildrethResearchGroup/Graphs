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
        
        self.textInspectorVM = TextInspectorViewModel(dataController)
        
        self.tableInspectorVM = TableInspectorViewModel(dataController, processDataManager)
        
    }
    
    
    convenience init(_ commonManagers: AppController.CommonManagers) {
        let cm = commonManagers
        
        self.init(cm.dataController, cm.selectionManager, cm.processedDataManager)
    }
}
