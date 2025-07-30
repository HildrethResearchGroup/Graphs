//
//  DataListViewModel.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import Collections
import SwiftUI

@Observable
@MainActor
class DataListViewModel {
    private var dataController: DataController
    private var selectionManager: SelectionManager

    
    var dataItems: Array<DataItem> {
        get { Array(dataController.visableItems) }
    }
    
    var selection: Set<DataItem.ID> {
        get { selectionManager.selectedDataItemIDs }
        set { selectionManager.selectedDataItemIDs = newValue }
    }
    
    private init(_ dataController: DataController, _ selectionManager: SelectionManager) {
        self.dataController = dataController
        self.selectionManager = selectionManager
    }
    
    convenience init(_ commonManagers: AppController.CommonManagers) {
        let cm = commonManagers
        self.init(cm.dataController, cm.selectionManager)
    }
    
    var sort: [KeyPathComparator<DataItem>] {
        get {
            dataController.sort
        }
        set {
            print("setting sort to: \(newValue)")
            dataController.sort = newValue
        }
    }
    
    var filter: String {
        get { dataController.filter }
        set { dataController.filter = newValue }
    }
    
}


// MARK: - Deleting Data
extension DataListViewModel {
    func deleteSelectedDataItems() {
        
        let dataItemsToDelete = Array(dataController.selectedDataItems)
        dataController.delete(dataItemsToDelete, andThenNodes: [])
    }
}



// MARK: - Open in Finder
extension DataListViewModel {
    func openInFinder(_ dataItem: DataItem) {
        
        var selectedDataItems = Set(dataController.selectedDataItems)
        
        selectedDataItems.insert(dataItem)
        
        let urls = selectedDataItems.map({ $0.url })
        
        urls.showInFinder()
    }
}


// MARK: - UI
extension DataListViewModel {
    func foregroundColor(for dataItem: DataItem) -> Color {
        
        let fileExists = dataItem.fileExists
        
        switch fileExists {
        case true: return .black
        case false:
            return .red
        }
    }
    
    var numberOfSelectedDataItems: Int {
        selection.count
    }
    
    var numberOfVisibleDataItems: Int {
        dataItems.count
    }
}


// MARK: - Exporting
extension DataListViewModel {
    func exportSelectionAsDataGraphFiles() {
        
        let nc = NotificationCenter.default
        
        nc.post(name: .exportSelectionAsDataGraphFiles, object: nil)
    }
}
