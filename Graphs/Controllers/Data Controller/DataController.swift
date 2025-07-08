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



@Observable
@MainActor
class DataController {
    private var container: ModelContainer
    
    var modelContext: ModelContext
    
    var delegate: DataControllerDelegate?
    
    var rootNodes: [Node] = []
    
    var parserSettings: [ParserSettings] = []
    
    var graphTemplates: [GraphTemplate] = []
    
    var sortNodesKeyPaths: [KeyPathComparator<Node>] = [
        .init(\.name)]
    
    
    // This is temporary and used to make the visibleItems a computed property
    // TODO: Remove when visibleItems transitioned to stored property that is updated manually
    var selectedNodes: [Node] = []
    
    var visableItems: OrderedSet<DataItem> {
        
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
            updateDataItems()
        }
    }
    
    var selectedDataItems: OrderedSet<DataItem> = []
    
    
    init(withDelegate delegate: DataControllerDelegate?) {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Node.self, DataItem.self, GraphTemplate.self, ParserSettings.self
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
        
        fetchData()
        
    }
    
    
    func allNodes() -> [Node] {
        do {
            let sortOrder = [SortDescriptor<Node>(\.name)]
            let descriptor = FetchDescriptor<Node>(sortBy: sortOrder)
            let output = try modelContext.fetch(descriptor)
            
            return output
            
        } catch  {
            print("DataController: Failed to Fetch All Nodes")
            return []
        }
    }
    
    
    // MARK: - Fetching Data
    func fetchData() {
        fetchRootNodes()
        fetchParserSettings()
        fetchGraphTemplates()
    }
    
    private func fetchRootNodes() {
         do {
             let sortOrder = [SortDescriptor<Node>(\.name)]
             //let predicate = #Predicate<Node>{ $0.nodeTypeStorage == 0}
             let predicate = #Predicate<Node> { $0.parent == nil}
             
             let descriptor = FetchDescriptor<Node>(predicate: predicate, sortBy: sortOrder)
             
             rootNodes = try modelContext.fetch(descriptor)
             
         } catch {
             print("DataController: Failed to Fetch Root Nodes")
         }
    }
    
    
    func fetchParserSettings() {
        do {
            let sortOrder = [SortDescriptor<ParserSettings>(\.name)]
            
            let descriptor = FetchDescriptor<ParserSettings>(sortBy: sortOrder)
            parserSettings = try modelContext.fetch(descriptor)
            
        } catch {
            print("DataController: Failed to Fetch ParserSettings")
        }
    }
    
    
    func fetchGraphTemplates() {
        do {
            let sortOrder = [SortDescriptor<GraphTemplate>(\.name)]
            
            let descriptor = FetchDescriptor<GraphTemplate>(sortBy: sortOrder)
            graphTemplates = try modelContext.fetch(descriptor)
        } catch {
            print("DataController: Failed to Fetch GraphTemplate")
        }
    }
    
    
    
    // MARK: - Filtering Selected DataItems
    func updateDataItems() {
        let ids = selectedDataItemIDs
        let items = self.visableItems
        let filteredItems = items.filter({ids.contains([$0.id])})
        
        selectedDataItems = filteredItems
    }
}
