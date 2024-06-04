//
//  GraphTemplate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

/// An entity which represents a graph template.
@objc(GraphTemplate)
public class GraphTemplate: NSManagedObject { }

// MARK: Core Data Properties
extension GraphTemplate {
	/// Returns a fetch request for the `GraphTemplate` entity type.
	/// - Returns: A fetch request for all `GraphTemplate` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<GraphTemplate> {
		return NSFetchRequest<GraphTemplate>(entityName: "GraphTemplate")
	}
	/// The file path that the data graph file is  located at.
	@NSManaged var path: URL?
	/// The name of the graph template.
	@NSManaged var name: String
	/// The directory items who have explicitly set this graph template as their default graph template. This does not include folders or files who are using their parent folder's default graph template.
	@NSManaged var directoryItems: NSSet
}

// MARK: Generated accessors for directoryItems
extension GraphTemplate {
	/// Sets a directory item's graph template to be this graph template.
	@objc(addDirectoryItemsObject:)
	@NSManaged public func addToDirectoryItems(_ value: DirectoryItem)
	/// Removes this graph template as the given directory item's default graph template.
	///
	/// If the directory item's default graph template was not this graph template, this will do nothing. Otherwise, the directory item's default graph template will be `nil`; for files, the default graph template will fallback on the parent folder's graph template.
	///
	/// - Note: The directory item may still use this graph template as its default graph template if its parent directory uses this graph template.
	@objc(removeDirectoryItemsObject:)
	@NSManaged public func removeFromDirectoryItems(_ value: DirectoryItem)
	/// Sets a set of directory items' graph templates to be this graph template.
	@objc(addDirectoryItems:)
	@NSManaged public func addToDirectoryItems(_ values: NSSet)
	/// Removes this graph template as the given directory items' default graph templates.
	///
	/// If a directory item's default graph template in the set was not this graph template, this will do nothing for that item. Otherwise, the directory item's default graph template will be `nil`; for files, the default parser will fallback on the parent folder's default graph template.
	///
	/// - Note: Each directory item may still use this parser as its default parser if its parent directory uses this parser, or if the directory item is a file, and this is the default parser for the file's file type.
	@objc(removeDirectoryItems:)
	@NSManaged public func removeFromDirectoryItems(_ values: NSSet)
}

// MARK: Derived Properties
extension GraphTemplate {
	/// The data graph controller created from the data graph file at the graph template's path.
	var controller: DGController? {
		guard let path = path else { return nil }
		return DGController(contentsOfFile: path.path)
	}
}
