//
//  SortCache.swift
//  Graphs
//
//  Created by Connor Barnes on 6/12/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

/// A subcontroller of `FileController` which manages the cache for the sorted file list items.
class SortCache {
	/// The file controller which control's the files displayed and sorting keys.
	private unowned let fileController: FileController
	/// Creates a sort cache from a file controller.
	/// - Parameter dataController: The file controller to use.
	init(fileController: FileController) {
		self.fileController = fileController
	}
	/// The cache that stores the data.
	private var sortCache: [Key: [File]] = [:]
	// This is used to make sure the proper background operation is canceled.
	/// An integer that uniquely represents the current sort operation.
	private var operationNumber = 0
}

// MARK: Sort Key
extension SortCache {
	/// A key which represents a sort description.
	struct Key: Hashable {
		/// The key to sort by.
		var sortKey: File.SortKey
		/// The direction to sort the items.
		var ascending: Bool
	}
}

// MARK: Sort Terminated Error
struct SortTerminatedError: Error {
	
}

// MARK: Helpers
extension SortCache {
	/// The current sort key for the file list.
	private var sortKey: File.SortKey? {
		return fileController.sortKey
	}
	/// The direction of sorting for file list.
	private var sortAscending: Bool {
		return fileController.sortAscending
	}
	/// Returns a closure that sorts the files by the selected sort key and direction.
	private var fileSort: ((File, File) -> Bool)? {
		guard let sortKey = sortKey else { return nil }
		
		// A function that sorts comparable types with support for optionals. nil values are placed first.
		func nilFirstSort<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool {
			guard let lhs = lhs else { return true }
			guard let rhs = rhs else { return false }
			return lhs < rhs
		}
		// A closure for sorting items by the give key in ascending order.
		let ascendingSort: (File, File) -> Bool = {
			switch sortKey {
			case .displayName:
				// When sorting ignore case
				return { $0.displayName.lowercased() < $1.displayName.lowercased() }
			case .collectionName:
				// When sorting ignore case
				return { nilFirstSort($0.parent?.displayName.lowercased(), $1.parent?.displayName.lowercased()) }
			case .dateCreated:
				return { nilFirstSort($0.dateCreated, $1.dateCreated) }
			case .dateModified:
				return { nilFirstSort($0.dateModified, $1.dateModified) }
			case .size:
				return { nilFirstSort($0.fileSize, $1.fileSize) }
			}
		}()
		
		if sortAscending {
			return ascendingSort
		} else {
			// To sort items in descending order, simply switch the order of the two arguments.
			return { ascendingSort($1, $0) }
		}
	}
}

// MARK: Interface
extension SortCache {
	/// Stops the current sort operation on the background thread.
	func abortBackgroundSort() {
		operationNumber += 1
	}
	/// Sorts the files by the given sort key and ascending modifier.
	/// - Parameter notify: If `true` a notification is sent indicating that the files were sorted. (`true` by default).
	func sortFiles(notify: Bool = true) {
		guard let sortKey = sortKey else { return }
		let key = Key(sortKey: sortKey, ascending: sortAscending)
		
		if let files = sortCache[key] {
			// The sorting is already cached
			fileController.filesToShow = files
		} else {
			// A new sort is being performed, so increase the operation number to cause any ongoing search to terminate early (each time elements are compared in the sorting closure, a check is done that the operation number is the same, otherwise it throws, ending the sort early.
			operationNumber += 1
			// The operation number at this time will be compared in the search closure to make sure we have not begun a new search operation (which would invalidate this operation)
			let currentOperationNumber = operationNumber
			
			var sortedFiles: [File] = []
			
			func backgroundWork() throws {
				let reverseKey = Key(sortKey: sortKey, ascending: !self.sortAscending)
				
				if let files: [File] = self.sortCache[reverseKey]?.reversed() {
					// The reverse sorting is already cached. Add the reverse to the cache
					// Reverse is used because it is significantly faster than sorting
					self.sortCache[key] = files
					sortedFiles = files
				} else {
					guard let fileSort = fileSort else { return }
					// No sort has been done for this key -- perform the search and add it to the cache
					let cancellableSort: (File, File) throws -> Bool = { (lhs, rhs) in
						// If the operation number has changed abort this sort
						if self.operationNumber != currentOperationNumber {
							throw SortTerminatedError()
						}
						return fileSort(lhs, rhs)
					}
					
					do {
						let files = try self.fileController.filesToShow.sorted(by: cancellableSort)
						sortedFiles = files
					}
				}
			}
			
			fileController.performBackgroundWork(backgroundWork) { [weak self] success in
				guard success else { return }
				// This is called only after the background thread finishes sorting, so there will be no issue with reading from sortedFiles. The cache value is assigned in the completion closure however because it needs to be assigned on the main thread rather than the background thread that the sorting happens on to prevent the cache being written to while the main thread is reading the cache
				self?.sortCache[key] = sortedFiles
				self?.fileController.filesToShow = sortedFiles
			}
		}

		if notify {
			let notification = Notification(name: .filesDisplayedDidChange)
			NotificationCenter.default.post(notification)
		}
	}
}
