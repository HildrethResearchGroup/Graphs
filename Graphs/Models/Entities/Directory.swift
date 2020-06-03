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
	@NSManaged public func __insertIntoChildren(_ value: DirectoryItem, at idx: Int)
	
	/// Removes the item at the given index from the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter idx: The index to remove the item at.
	@objc(removeObjectFromChildrenAtIndex:)
	@NSManaged public func __removeFromChildren(at idx: Int)
	
	/// Adds multiple items to the directory at the given index set.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameters:
	///   - values: The items to add to the directory.
	///   - indexes: The indexes to insert the items at.
	@objc(insertChildren:atIndexes:)
	@NSManaged public func __insertIntoChildren(_ values: [DirectoryItem], at indexes: NSIndexSet)
	
	/// Removes the items at the given indexes from the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter indexes: The indexes to remove the items at.
	@objc(removeChildrenAtIndexes:)
	@NSManaged public func __removeFromChildren(at indexes: NSIndexSet)
	
	/// Replaces the item at the given index with the given item.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameters:
	///   - idx: The index of the item to replace.
	///   - value: The item to replace the existing item.
	@objc(replaceObjectInChildrenAtIndex:withObject:)
	@NSManaged public func __replaceChildren(at idx: Int, with value: DirectoryItem)
	
	/// Replaces the items at the given indexes with the given items.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameters:
	///   - indexes: The indexes of the items to replace.
	///   - values: The items to replace the existing items.
	@objc(replaceChildrenAtIndexes:withChildren:)
	@NSManaged public func __replaceChildren(at indexes: NSIndexSet, with values: [DirectoryItem])
	
	/// Adds a new item to the end of the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter value: The item to add to the directory.
	@objc(addChildrenObject:)
	@NSManaged public func __addToChildren(_ value: DirectoryItem)
	
	/// Removes the given item from the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter value: The item to remove from the directory.
	@objc(removeChildrenObject:)
	@NSManaged public func __removeFromChildren(_ value: DirectoryItem)
	
	/// Adds new items to the end of the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter values: The items to add to the directory.
	@objc(addChildren:)
	@NSManaged public func __addToChildren(_ values: NSOrderedSet)
	
	/// Removes the given items from the directory.
	///
	/// This method is public because it is managed by Core Data. However, it should not be called directly. Instead call the method without underscores.
	///
	/// - Parameter values: The items to remove from the directory.
	@objc(removeChildren:)
	@NSManaged public func __removeFromChildren(_ values: NSOrderedSet)
}

// MARK: Custom accessors
extension Directory {
	/// Adds a new item to the directory at the given index.
	/// - Parameters:
	///   - value: The item to add to the directory.
	///   - idx: The index to insert the item at.
	func insertIntoChildren(_ value: DirectoryItem, at idx: Int) {
		__insertIntoChildren(value, at: idx)
		calculateSubDirectories()
	}
	
	/// Removes the item at the given index from the directory.
	/// - Parameter idx: The index to remove the item at.
	func removeFromChildren(at idx: Int) {
		__removeFromChildren(at: idx)
		calculateSubDirectories()
	}
	
	/// Adds multiple items to the directory at the given index set.
	/// - Parameters:
	///   - values: The items to add to the directory.
	///   - indexes: The indexes to insert the items at.
	func insertIntoChildren(_ values: [DirectoryItem], at indexes: NSIndexSet) {
		__insertIntoChildren(values, at: indexes)
		calculateSubDirectories()
	}
	
	/// Removes the items at the given indexes from the directory.
	/// - Parameter indexes: The indexes to remove the items at.
	func removeFromChildren(at indexes: NSIndexSet) {
		__removeFromChildren(at: indexes)
		calculateSubDirectories()
	}
	
	/// Replaces the item at the given index with the given item.
	/// - Parameters:
	///   - idx: The index of the item to replace.
	///   - value: The item to replace the existing item.
	func replaceChildren(at idx: Int, with value: DirectoryItem) {
		__replaceChildren(at: idx, with: value)
		calculateSubDirectories()
	}
	
	/// Replaces the items at the given indexes with the given items.
	/// - Parameters:
	///   - indexes: The indexes of the items to replace.
	///   - values: The items to replace the existing items.
	func replaceChildren(at indexes: NSIndexSet, with values: [DirectoryItem]) {
		__replaceChildren(at: indexes, with: values)
		calculateSubDirectories()
	}
	
	/// Adds a new item to the end of the directory.
	/// - Parameter value: The item to add to the directory.
	func addToChildren(_ value: DirectoryItem) {
		__addToChildren(value)
		calculateSubDirectories()
	}
	
	/// Removes the given item from the directory.
	/// - Parameter value: The item to remove from the directory.
	func removeFromChildren(_ value: DirectoryItem) {
		__removeFromChildren(value)
		calculateSubDirectories()
	}
	
	/// Adds new items to the end of the directory.
	/// - Parameter values: The items to add to the directory.
	func addToChildren(_ values: NSOrderedSet) {
		__addToChildren(values)
		calculateSubDirectories()
	}
	
	/// Removes the given items from the directory.
	/// - Parameter values: The items to remove from the directory.
	func removeFromChildren(_ values: NSOrderedSet) {
		__removeFromChildren(values)
		calculateSubDirectories()
	}
}

// MARK: Derived properties
extension Directory {
	/// The default name of new directories
	static let defaultDisplayName = "New Directory"
	/// A cache that stores a directory's subdidrectories. This is added as a static dictionary rather than as a member variable because adding member variables that are not managed by CoreData is not reccomended.
	private static var subdirectoryCache: [Directory: [Directory]] = [:]
	/// Invalidates all cached properties.
	static func invalidateCache() {
		subdirectoryCache = [:]
	}
	/// Calculates the sub directories for the directory and adds the calculation to the cache.
	/// - Returns: The calculated sub directories.
	@discardableResult
	private func calculateSubDirectories() -> [Directory] {
		// TODO: Change this function to be more effecient. Currently it goes through all of the children to recompute this. Instead, this could be function dependent so that for example, when appending a Directory, the directory could simply be appended to the end of the cache as well.
		let subdirectories = children.compactMap { $0 as? Directory }
		Self.subdirectoryCache[self] = subdirectories
		return subdirectories
	}
	/// The direct (not recursive) subdirectories of this directory.
	var subdirectories: [Directory] {
		// The values are stored in a cache to prevent uncessesarily recomputing this property. calculateSubDirectories() automatically adds the calculation to the cache
		return Self.subdirectoryCache[self] ?? calculateSubDirectories()
	}
	/// The recursive parent directories of this directory.
	var ansestors: Set<Directory> {
		var ansestors: Set<Directory> = []
		// TODO: Is parent supposed to be in the set or not? It is an ansestor but will it introduce any bugs to change it?
		var parent = self.parent
		
		while let nextParent = parent {
			ansestors.insert(nextParent)
			parent = nextParent.parent
		}
		
		return ansestors
	}
	/// Returns `true` if this directory is a descendent of the given directory.
	/// - Parameter directory: The directory to check if this directory is a descendent of.
	/// - Returns: `true` if this directory is a descendent of the given directory, otherwise `false`.
	func isDescendent(of directory: Directory) -> Bool {
		// The first ancestory is the parent
		var ancestor = self.parent
		
		repeat {
			if directory == ancestor { return true }
			// Climb up the ancestor tree until there are no more parents
			ancestor = ancestor?.parent
		} while ancestor != nil
		
		// None of the ancestors were the given directory, so self is not a decesndent of directory
		return false
	}
	
	/// Returns `true` if this directory is a descendent of any of the given directories.
	/// - Parameter directories: The directories to check if this directory is a descendent of.
	/// - Returns: `true` if this directory is a descendent of any of the given directories, otherwise `false`.
	func isDescendent(of directories: Set<Directory>) -> Bool {
		// The first candidate is the parent directory
		var ancestor = self.parent
		if ancestor == nil { return false }
		
		repeat {
			// We can force unwrap becuase the while condition is ancestor != nil and the same check is performed before the loop
			if directories.contains(ancestor!) { return true }
			// Climb up the ancestor tree until there are no more parents
			ancestor = ancestor?.parent
		} while ancestor != nil
		
		// None of the ancestors were the given directory, so self is not a decesndent of directory
		return false
	}
}
