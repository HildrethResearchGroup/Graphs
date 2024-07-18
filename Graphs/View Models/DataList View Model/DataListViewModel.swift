//
//  DataListViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

@Observable
class DataListViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager
    
    var dataItems: [DataItem] {
        get { dataController.visableItems }
    }
    
    var selection: Set<DataItem.ID> {
        get { selectionManager.selectedDataItemIDs }
        set { selectionManager.selectedDataItemIDs = newValue }
    }
    
    init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
}
