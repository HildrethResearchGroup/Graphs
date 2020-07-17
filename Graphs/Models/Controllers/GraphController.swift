//
//  GraphController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

class GraphController {
	unowned let dataController: DataController
	
	var graphTemplates: [GraphTemplate] = []
	
	init(dataController: DataController) {
		self.dataController = dataController
		
	}
}

// MARK: Helpers
extension GraphController {
	var context: NSManagedObjectContext {
		return dataController.context
	}
}

// MARK: Interface
extension GraphController {
	/// Loads the imported graph templates from Core Data.
	func loadGraphTemplates() {
		let fetchRequest: NSFetchRequest<GraphTemplate> = GraphTemplate.fetchRequest()
		do {
			graphTemplates = try context.fetch(fetchRequest)
		} catch {
			print("[ERROR] Failed to load graph templates from Core Data store: \(error)")
		}
	}
	/// Imports a graph template from a file url.
	/// - Parameter url: The file url of the graph template.
	/// - Returns: The graph template and its associated controller if it could successfully be created, otherwise `nil`.
	func importGraphTemplate(from url: URL) -> (template: GraphTemplate, controller: DGController)? {
		guard url.isFileURL else { return nil }
		guard url.lastPathComponent.split(separator: ".").last == "dgraph" else { return nil }
		
		guard let controller = DGController(contentsOfFile: url.path) else { return nil }
		
		let name = url.lastPathComponent.split(separator: ".").first ?? "New Graph Template"
		
		let template = GraphTemplate(context: context)
		template.path = url
		template.name = String(name)
		graphTemplates.append(template)
		dataController.setNeedsSaved()
		return (template: template, controller: controller)
	}
	/// Deletes the diven graph template.
	/// - Parameter graphTemplate: The graph template to remove.
	func remove(graphTemplate: GraphTemplate) {
		graphTemplates.removeAll { $0 === graphTemplate }
		context.delete(graphTemplate)
		dataController.setNeedsSaved()
	}
	/// Renames the graph template.
	/// - Parameters:
	///   - graphTemplate: The graph template to rename.
	///   - newName: The new name of the template.
	func rename(graphTemplate: GraphTemplate, to newName: String) {
		graphTemplate.name = newName
		dataController.setNeedsSaved()
	}
}
