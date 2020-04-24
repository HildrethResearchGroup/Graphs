//
//  Directory+CoreDataClass.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//
//

import Foundation
import CoreData

/// An entity that represents a directory which can contain files or other directories.
@objc(Directory)
public class Directory: DirectoryItem { }

// MARK: Core Data Properties
extension Directory {
	/// Returns a fetch request for the `Directory` entity type.
	/// - Returns: A fetch request for all `Directory` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Directory> {
		return NSFetchRequest<Directory>(entityName: "Directory")
	}
	/// Is `true` if the item is collapsed in the sourcelist, otherwise is `false`.
	///
	/// This is needed to enable saving the collapsed state for NSOutlineView without using an NSTreeController or persistant objects.
	@NSManaged public var collapsed: Bool
	/// An ordered list of the items in the directory.
	@NSManaged public var children: NSOrderedSet
}

// MARK: Generated accessors for children
extension Directory {
	
	/// Adds a new item to the directory at the given index.
	/// - Parameters:
	///   - value: The item to add to the directory.
	///   - idx: The index to insert the item at.
	@objc(insertObject:inChildrenAtIndex:)
	@NSManaged public func insertIntoChildren(_ value: DirectoryItem, at idx: Int)
	
	/// Removes the item at the given index from the directory.
	/// - Parameter idx: The index to remove the item at.
	@objc(removeObjectFromChildrenAtIndex:)
	@NSManaged public func removeFromChildren(at idx: Int)
	
	/// Adds multiple items to the directory at the given index set.
	/// - Parameters:
	///   - values: The items to add to the directory.
	///   - indexes: The indexes to insert the items at.
	@objc(insertChildren:atIndexes:)
	@NSManaged public func insertIntoChildren(_ values: [DirectoryItem], at indexes: NSIndexSet)
	
	/// Removes the items at the given indexes from the directory.
	/// - Parameter indexes: The indexes to remove the items at.
	@objc(removeChildrenAtIndexes:)
	@NSManaged public func removeFromChildren(at indexes: NSIndexSet)
	
	/// Replaces the item at the given index with the given item.
	/// - Parameters:
	///   - idx: The index of the item to replace.
	///   - value: The item to replace the existing item.
	@objc(replaceObjectInChildrenAtIndex:withObject:)
	@NSManaged public func replaceChildren(at idx: Int, with value: DirectoryItem)
	
	/// Replaces the items at the given indexes with the given items.
	/// - Parameters:
	///   - indexes: The indexes of the items to replace.
	///   - values: The items to replace the existing items.
	@objc(replaceChildrenAtIndexes:withChildren:)
	@NSManaged public func replaceChildren(at indexes: NSIndexSet, with values: [DirectoryItem])
	
	/// Adds a new item to the end of the directory.
	/// - Parameter value: The item to add to the directory.
	@objc(addChildrenObject:)
	@NSManaged public func addToChildren(_ value: DirectoryItem)
	
	/// Removes the given item from the directory.
	/// - Parameter value: The item to remove from the directory.
	@objc(removeChildrenObject:)
	@NSManaged public func removeFromChildren(_ value: DirectoryItem)
	
	/// Adds new items to the end of the directory.
	/// - Parameter values: The items to add to the directory.
	@objc(addChildren:)
	@NSManaged public func addToChildren(_ values: NSOrderedSet)
	
	/// Removes the given items from the directory.
	/// - Parameter values: The items to remove from the directory.
	@objc(removeChildren:)
	@NSManaged public func removeFromChildren(_ values: NSOrderedSet)
}

// MARK: Derived properties
extension Directory {
	/// The direct (not recursive) subdirectories of this directory.
	var subdirectories: [Directory] {
		// TODO: Add a caching mechanism for this. NSOulineView calls this (n+1) times where n is the length of the colleciton. This makes NSOutlineView take O(n^2) time, but with caching it would be only O(n).
		return children.compactMap { $0 as? Directory }
	}
}
