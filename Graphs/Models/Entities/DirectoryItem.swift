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
	/// The parser to use to parse the item
	@NSManaged public var parser: Parser?
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
