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
	
	var sortQueue = DispatchQueue(label: "sortQueue", qos: .utility)
	
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
	
	func invalidate() {
		sortCache = [:]
	}
	
	func sortFiles(notify: Bool = true) {
		guard let sortKey = sortKey else { return }
		let key = Key(sortKey: sortKey, ascending: sortAscending)
		
		let sortedFiles: [File]
		
		if let files = sortCache[key] {
			// The sorting is already cached
			sortedFiles = files
		} else {
			let reverseKey = Key(sortKey: sortKey, ascending: !sortAscending)
			if let files: [File] = sortCache[reverseKey]?.reversed() {
				// The reverse sorting is already cached. Add the reverse to the cache
				// Reverse is used because it is significantly faster than sorting
				sortCache[key] = files
				sortedFiles = files
			} else {
				// No sort has been done for this key -- perform the search and add it to the cache.
				let files = directoryController.filesToShow.sorted(by: fileSort!)
				sortCache[key] = files
				sortedFiles = files
			}
		}
		
		directoryController.filesToShow = sortedFiles

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
