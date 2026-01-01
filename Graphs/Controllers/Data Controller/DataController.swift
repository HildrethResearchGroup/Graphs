//
//  DataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI
import OrderedCollections
import OSLog



@Observable
@MainActor
class DataController {
    private var container: ModelContainer
    
    var modelContext: ModelContext
    
    var delegate: DataControllerDelegate?
    
    var rootNodes: [Node] = []
    
    var parserSettings: [ParserSettings] = []
    
    var graphTemplates: [GraphTemplate] = []
    
    var fileExtensions: [FileExtension] = [] {
        didSet {
            print("file Extensions changed")
        }
    }
    
    
    // MARK: - Data Items
    var allDataItems: [DataItem] = []
    
    private var _filter: String = ""
    var filter: String {
        get {
            _filter
        }
        set {
            let oldValue = _filter
            let incomingValue = newValue
            _filter = newValue
            
            if incomingValue != oldValue {
                updateFilteredDataItems()
            }
        }
    }
    
    
    private var filteredDataItems: OrderedSet<DataItem> = [] {
        didSet {
            updateSelectedDataItems()
        }
    }
    
    
    var visableItems: OrderedSet<DataItem> {
        
        let sortedDataItems = OrderedSet(filteredDataItems.sorted(using: sort))
        
        return sortedDataItems
    }
    

    
    var sort: [KeyPathComparator<DataItem>] = [.init(\.name), .init(\.nodePath)] {
        didSet {
            updateFilteredDataItems()
        }
    }
    
    
    // MARK: - Selections
    // This is temporary and used to make the visibleItems a computed property
    // TODO: Remove when visibleItems transitioned to stored property that is updated manually
    
    var selectedNodeIDs: [Node.ID] = [] {
        didSet {
            updateSelectedNodes()
        }
    }
    
    var selectedNodes: [Node] = [] {
        didSet {
            updateFilteredDataItems()
        }
    }
    
    
    private var dataItemsFromSelectedNodes: OrderedSet<DataItem> {
        // For initial simplicity, we will make this a computed property
        get {
            var items: OrderedSet<DataItem> = []
            for nextNode in selectedNodes {
                items.formUnion(nextNode.flattenedDataItems())
            }
            
            return items
        }
    }
    
    
    var selectedDataItemIDs: [DataItem.ID] = [] {
        didSet {
            updateSelectedDataItems()
        }
    }
    
    var selectedDataItems: [DataItem] = []
    
    
    // MARK: - Initialization
    init(withDelegate delegate: DataControllerDelegate?) {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Node.self, DataItem.self, GraphTemplate.self, ParserSettings.self, FileExtension.self
            ])
            
            
            let storageLocation = URL.swiftDataStorageLocation
            
            
            let modelConfiguration = ModelConfiguration(schema: schema, url: storageLocation, allowsSave: true)
            
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        
        container = sharedModelContainer
        
        
        modelContext = ModelContext(sharedModelContainer)

        self.delegate = delegate
        
        fetchAllObjects()
        
        updateFilteredDataItems()

    }
    
    
    
    // MARK: - Nodes
    func allNodes() -> [Node] {
        do {
            let sortOrder = [SortDescriptor<Node>(\.name)]
            let descriptor = FetchDescriptor<Node>(sortBy: sortOrder)
            let output = try modelContext.fetch(descriptor)
            
            return output
            
        } catch  {
            Logger.dataController.info("DataController: Failed to Fetch All Nodes")
            return []
        }
    }
    
    func topNode() -> Node? {
        return rootNodes.first
    }
    
    
    
    
    
    // MARK: - Fetching Data
    func fetchAllObjects() {
        fetchRootNodes()
        fetchParserSettings()
        fetchGraphTemplates()
        fetchDataItems()
        fetchFileExtensions()
        updateFilteredDataItems()
    }
    
    
    private func fetchDataItems() {
        do {
            let sortOrder = [SortDescriptor<DataItem>(\.name)]
            let descriptor = FetchDescriptor<DataItem>(sortBy: sortOrder)
            allDataItems = try modelContext.fetch(descriptor)
        } catch  {
            Logger.dataController.info("DataController: Failed to Fetch All DataItems")
            allDataItems = []
        }
    }
    
    private func fetchRootNodes() {
         do {
             let sortOrder = [SortDescriptor<Node>(\.name)]
             //let predicate = #Predicate<Node>{ $0.nodeTypeStorage == 0}
             let predicate = #Predicate<Node> { $0.parent == nil}
             
             let descriptor = FetchDescriptor<Node>(predicate: predicate, sortBy: sortOrder)
             
             rootNodes = try modelContext.fetch(descriptor)
             
         } catch {
             Logger.dataController.info("DataController: Failed to Fetch Root Nodes")
         }
    }
    
    
    func fetchParserSettings() {
        do {
            let sortOrder = [SortDescriptor<ParserSettings>(\.name)]
            
            let descriptor = FetchDescriptor<ParserSettings>(sortBy: sortOrder)
            parserSettings = try modelContext.fetch(descriptor)
            
        } catch {
            Logger.dataController.info("DataController: Failed to Fetch ParserSettings")
        }
    }
    
    
    func fetchGraphTemplates() {
        do {
            let sortOrder = [SortDescriptor<GraphTemplate>(\.name)]
            
            let descriptor = FetchDescriptor<GraphTemplate>(sortBy: sortOrder)
            graphTemplates = try modelContext.fetch(descriptor)
        } catch {
            Logger.dataController.info("DataController: Failed to Fetch GraphTemplate")
        }
    }
    
    
    func fetchFileExtensions() {
        do {
            let sortOrder = [SortDescriptor<FileExtension>(\.fileExtension)]
            let descriptor = FetchDescriptor<FileExtension>(sortBy: sortOrder)
            fileExtensions = try modelContext.fetch(descriptor)
            
            if fileExtensions.isEmpty {
                let defaultExtensions = FileExtension.defaultExtensions
                
                for nextExtension in defaultExtensions {
                    modelContext.insert(nextExtension)
                }
            }
            
        } catch {
            Logger.dataController.info("DataController: Failed to Fetch File Extensions")
            fileExtensions = []
        }
    }
    
    
    
    // MARK: - Filtering Selected DataItems
    func updateSelectedNodes() {
        let ids = selectedNodeIDs
        
        let nodes = allNodes()
        
        let filteredNodes = nodes.filter( { ids.contains([$0.id]) })
        
        self.selectedNodes = filteredNodes
    }
    
    func updateSelectedDataItems() {
        
        let ids = selectedDataItemIDs
        let items = self.visableItems
        let filteredItems = items.filter({ids.contains([$0.id])})
        let sortedFilteredItems = filteredItems.sorted(using: sort)
        
        selectedDataItems = sortedFilteredItems
    }
    

    private func updateFilteredDataItems() {
        
        if filter.isEmpty {
            self.filteredDataItems = dataItemsFromSelectedNodes
        } else {
            let filteredItems = dataItemsFromSelectedNodes.filter({$0.containsFilter(filter)})
            
            let filteredItemIDs = filteredItems.map({ $0.id })
            
            delegate?.filterDidChange(currentlySelectedDataItemIDs: filteredItemIDs)
            
            self.filteredDataItems = filteredItems
        }
    }
    
}
