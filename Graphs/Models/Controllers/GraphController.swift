//
//  GraphController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

class GraphController {
	/// The data controller which controls the Core Data store.
	unowned let dataController: DataController
	/// The graph templates that have been imported.
	var graphTemplates: [GraphTemplate] = []
	/// Creates a file controller from a data controller.
	/// - Parameter dataController: The data controller to use.
	init(dataController: DataController) {
		self.dataController = dataController
		
	}
}

// MARK: Helpers
extension GraphController {
	/// The Core Data context.
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
		// If a controller can't be created from the file, then it is an invalid template file, so don't allow the template to be imported.
		guard let controller = DGController(contentsOfFile: url.path) else { return nil }
		// Name the graph template the name of the file it was imported from.
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
	/// The graph template to use for the given directory item.
	/// - Parameter directoryItem: The item to find the template for.
	/// - Returns: The graph template that should be used for file types or the default graph template for directory types.
	func graphTemplate(for directoryItem: DirectoryItem) -> GraphTemplate? {
		if let customGraphTemplate = directoryItem.graphTemplate { return customGraphTemplate }
		if let parent = directoryItem.parent {
			return graphTemplate(for: parent)
		}
		return nil
	}
}