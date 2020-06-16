//
//  SortCache.swift
//  Graphs
//
//  Created by Connor Barnes on 6/12/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

class SortCache {
	private unowned let fileController: FileController
	
	init(fileController: FileController) {
		self.fileController = fileController
	}
	
	private var sortCache: [Key: [File]] = [:]
	
	private var operationNumber = 0
}

// MARK: Sort Key
extension SortCache {
	struct Key: Hashable {
		var sortKey: File.SortKey
		var ascending: Bool
	}
}

// MARK: Sort Terminated Error
struct SortTerminatedError: Error {
	
}

// MARK: Helpers
extension SortCache {
	private var sortKey: File.SortKey? {
		return fileController.sortKey
	}
	
	private var sortAscending: Bool {
		return fileController.sortAscending
	}
	
	private var fileSort: ((File, File) -> Bool)? {
		guard let sortKey = sortKey else { return nil }
		
		func nilFirstSort<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool {
			guard let lhs = lhs else { return true }
			guard let rhs = rhs else { return false }
			return lhs < rhs
		}
		
		let ascendingSort: (File, File) -> Bool = {
			switch sortKey {
			case .displayName:
				return { $0.displayName.lowercased() < $1.displayName.lowercased() }
			case .collectionName:
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
			// A new sort is being performed to increase the operation number to cause any ongoing search to terminate early
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
						self.sortCache[key] = files
						sortedFiles = files
					}
				}
			}
			
			fileController.performBackgroundWork(backgroundWork) { [weak self] success in
				guard success else { return }
				
				self?.sortCache[key] = sortedFiles
				self?.fileController.filesToShow = sortedFiles
			}
		}

		if notify {
			let notification = Notification(name: .filesToShowChanged)
			NotificationCenter.default.post(notification)
		}
	}
}
