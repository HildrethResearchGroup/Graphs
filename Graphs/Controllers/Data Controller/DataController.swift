//
//  DataManager.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI


// TODO: Import Collections
// import OrderedCollections


@Observable
class DataController {
    private var container: ModelContainer
    
    var modelContext: ModelContext
    
    var delegate: DataControllerDelegate?
    
    var rootNodes: [Node] = []
    
    var sortNodesKeyPaths: [KeyPathComparator<Node>] = [
        .init(\.name)]

    
    // This is temporary and used to make the visibleItems a computed property
    // TODO: Remove when visibleItems transitioned to stored property that is updated manually
    var selectedNodes: [Node] = []
    
    var visableItems: [DataItem] {
        
        // For initial simplicity, we will make this a computed property
        // TODO: Switch visibleItems to stored property that is updated manually
        get {
            // UPDATE
            // Make this an OrderedSet to ensure that items aren't duplicated
            // TODO: Make OrderedSet
            // var items: OrderedSet<ImageItem> = []
            var items: Set<DataItem> = []
            
            // U
            for nextNode in selectedNodes {
                //items.append(contentsOf: nextNode.flattenedDataItems())
                // TODO: Replace with OrderedSet
                items.formUnion(nextNode.flattenedDataItems())
            }
            
            // UPDATE
            return Array(items)
        }
    }
    

    var selectedDataItemIDs: [PersistentIdentifier] = [] {
        didSet {
            updateDataItems()
        }
    }
    
    var selectedDataItems: [DataItem] = []
    
    
    init(withDelegate delegate: DataControllerDelegate?) {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Node.self, DataItem.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

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
    
    
    // MARK: - Fetching Data
    func fetchData() {
        do {
            let sortOrder = [SortDescriptor<Node>(\.name)]
            let predicate = #Predicate<Node>{ $0.nodeTypeStorage == 0}
            
            let descriptor = FetchDescriptor<Node>(predicate: predicate, sortBy: sortOrder)
            rootNodes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed")
        }
    }
    
    // ADD
    // MARK: - Filtering Selected DataItems
    func updateDataItems() {
        let ids = selectedDataItemIDs
        let items = self.visableItems
        let filteredItems = items.filter({ids.contains([$0.id])})
        
        selectedDataItems = filteredItems
    }
    
    
    
    // MARK: - Adding Nodes
    func createEmptyNode(withParent parent: Node?) {
        let newNode = Node(url: nil, parent: parent)
        
        modelContext.insert(newNode)
        
        delegate?.newData(nodes: [newNode], andDataItems: [])
        
        fetchData()
    }
}
