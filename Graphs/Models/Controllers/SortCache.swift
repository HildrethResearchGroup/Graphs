//
//  SortCache.swift
//  Graphs
//
//  Created by Connor Barnes on 6/12/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

class SortCache {
	private unowned let directoryController: DirectoryController
	
	init(directoryController: DirectoryController) {
		self.directoryController = directoryController
	}
	
	private var sortCache: [Key: [File]] = [:]
	
	var sortKey: File.SortKey? {
		return directoryController.sortKey
	}
	
	var sortAscending: Bool {
		return directoryController.sortAscending
	}
	
	var operationNumber = 0
	var workItem: DispatchWorkItem?
	
	func abortBackgroundSort() {
		operationNumber += 1
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
	
	func sortFiles(notify: Bool = true) {
		guard let sortKey = sortKey else { return }
		let key = Key(sortKey: sortKey, ascending: sortAscending)
		
		if let files = sortCache[key] {
			// The sorting is already cached
			directoryController.filesToShow = files
		} else {
			
			directoryController.beginWork()
			
			operationNumber += 1
			let currentOperationNumber = operationNumber
			
			workItem = DispatchWorkItem {
				let sortedFiles: [File]
				let reverseKey = Key(sortKey: sortKey, ascending: !self.sortAscending)
				
				if let files: [File] = self.sortCache[reverseKey]?.reversed() {
					// The reverse sorting is already cached. Add the reverse to the cache
					// Reverse is used because it is significantly faster than sorting
					self.sortCache[key] = files
					sortedFiles = files
				} else {
					// No sort has been done for this key -- perform the search and add it to the cache.
					let cancellableSort: (File, File) throws -> Bool = { (lhs, rhs) in
						if self.operationNumber != currentOperationNumber {
							throw SortTerminatedError()
						}
						return self.fileSort!(lhs, rhs)
					}
					guard let files = try? self.directoryController.filesToShow.sorted(by: cancellableSort) else { return }
					self.sortCache[key] = files
					sortedFiles = files
				}
				
				DispatchQueue.main.async { [weak self] in
					self?.sortCache[key] = sortedFiles
					self?.directoryController.filesToShow = sortedFiles
					self?.directoryController.endWork()
				}
			}
			
			directoryController.workQueue.async(execute: workItem!)
			
			
		}

		if notify {
			let notification = Notification(name: .filesToShowChanged)
			NotificationCenter.default.post(notification)
		}
	}
}

extension SortCache {
	struct Key: Hashable {
		var sortKey: File.SortKey
		var ascending: Bool
	}
}

struct SortTerminatedError: Error {
	
}
