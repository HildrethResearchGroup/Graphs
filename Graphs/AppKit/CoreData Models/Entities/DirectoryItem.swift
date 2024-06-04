//
//  DirectoryItem+CoreDataClass.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//
//

import Foundation
import CoreData

/// An entity that represents a directory item. This can be either a file or directory.
///
/// This is an abstract class and should never be directly initialized. Instead, subclassed of `File` or `Directory` should be used.
@objc(DirectoryItem)
public class DirectoryItem: NSManagedObject { }

// MARK: Core Data Properties
extension DirectoryItem {
	/// Returns a fetch request for the `DirectoryItem` entity type.
	/// - Returns: A fetch request for all `DirectoryItem` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<DirectoryItem> {
		return NSFetchRequest<DirectoryItem>(entityName: "DirectoryItem")
	}
	/// The file path for the directory if it is linked to a physical directory. For files this should never be `nil`, as all files must be stored on the file system somewhere.
	@NSManaged public var path: URL?
	/// A custom display name if the directory has been renamed.
	///
	/// If the directory is not linked to a physical directory (`path == nil`), then this is simply that name of the directory.
	@NSManaged public var customDisplayName: String?
	/// The directory that the item is in. If this is `nil`, then the item is the root directory.
	@NSManaged public var parent: Directory?
	/// The explicitly defined parser for the item.
	///
	///  For `File` entities, if this value is not `nil`, then this will be the parser used to parse that file. For `Directory` entities, if this value is not `nil`, then this will be the parser used for files within the directory that do not have an explicitly set parser, as well as for files within subdirectories of this directory that do not have an explicitly set parser. Files that are set to use the default for their file type will not fall back on their parent directory's expliticly set parser.
	///
	/// - Note: If this is `nil`, the parser used to parser the item is determined by the method `DataController.parser(for:)`.
	@NSManaged public var parser: Parser?
	/// The explicitly defined graph template for the item.
	///
	///  For `File` entities, if this value is not `nil`, then this will be the graph template used to graph that file. For `Directory` entities, if this value is not `nil`, then this will be the graph template used for files within the directory that do not have an explicitly set graph template, as well as for files within subdirectories of this directory that do not have an explicitly set graph template.
	///
	/// - Note: If this is `nil`, the parser used to parser the item is determined by the method `DataController.graphTemplate(for:)`.
	@NSManaged public var graphTemplate: GraphTemplate?
}

// MARK: Derived Properties
extension DirectoryItem {
	/// Returns the name to display in the sidebar.
	var displayName: String {
		// Always use the custom name if it is defined
		if let custom = customDisplayName {
			return custom
		}
		// Otherwise use the filename if it points to a physical file or directory.
		if let path = path {
			return path.lastPathComponent
		}
		return ""
	}
}
