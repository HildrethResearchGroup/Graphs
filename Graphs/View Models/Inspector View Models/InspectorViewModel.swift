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
    
    var parserSettingsVM: ParserSettingsViewModel
    
    var graphTemplateInspectorVM: GraphTemplateInspectorViewModel
    
    var dataItemsVM: DataItemsInspectorViewModel
    
    var nodeInspectorVM: NodeInspectorViewModel
    
    var textInspectorVM: TextInspectorViewModel
    
    
    var firstDataItem: DataItem? {
        dataController.selectedDataItems.first
    }
    
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
        
        self.parserSettingsVM = ParserSettingsViewModel(dataController, selectionManager)
        
        self.graphTemplateInspectorVM = GraphTemplateInspectorViewModel(dataController, selectionManager)
        
        self.dataItemsVM = DataItemsInspectorViewModel(dataController, selectionManager)
        
        self.nodeInspectorVM = NodeInspectorViewModel(dataController, selectionManager)
        
        self.textInspectorVM = TextInspectorViewModel(dataController)
        
    }
}
