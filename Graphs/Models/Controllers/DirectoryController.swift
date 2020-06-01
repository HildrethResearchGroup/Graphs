//
//  DirectoryController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/25/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation
import CoreData

class DirectoryController: NSObject {
	private unowned let dataController: DataController
	/// The root directory. All directories are decendents of this directory.
	var rootDirectory: Directory?
	/// The currently selected directories.
	var selectedDirectories: [Directory] = [] {
		didSet {
			// When the selection changes, the file list table needs to be updated. It will respond to this notification.
			filesToShow = files(in: selectedDirectories)
			let notification = Notification(name: .directorySelectionChanged)
			NotificationCenter.default.post(notification)
		}
	}
	/// The files in the currently selected directories.
	private(set) var filesToShow: [File] = []
	
	init(dataController: DataController) {
		self.dataController = dataController
		super.init()
		registerObservers()
	}
	
	@objc func didUndo(_ notification: Notification) {
		Directory.invalidateCache()
		// Send a notificatoin that the undo has been processed and that view controllers should no update their contents
		let notification = Notification(name: .didProcessUndo)
		NotificationCenter.default.post(notification)
	}
	
	func registerObservers() {
		// Must register for undo/redo notifications to invalidate any caches.
		NotificationCenter.default.addObserver(self, selector: #selector(didUndo(_:)), name: .NSUndoManagerDidUndoChange, object: dataController.persistentContainer.viewContext.undoManager)
		NotificationCenter.default.addObserver(self, selector: #selector(didUndo(_:)), name: .NSUndoManagerDidRedoChange, object: dataController.persistentContainer.viewContext.undoManager)
	}
	
	@discardableResult
	func createSubdirectory(in parent: Directory) -> Directory {
		let subdirectory = Directory(context: dataController.persistentContainer.viewContext)
		parent.addToChildren(subdirectory)
		parent.collapsed = false
		dataController.setNeedsSaved()
		return subdirectory
	}
	
	func remove(directory: Directory) {
		if let parent = directory.parent {
			directory.parent = nil
			parent.removeFromChildren(directory)
		}
		dataController.setNeedsSaved()
	}
}

// MARK: Directory management
extension DirectoryController {
	/// Fetches the root directory if it exists. Otherwise creates the root directory.
	/// - Returns: The (possibly newly created) root directory.
	func loadRootDirectory() {
		/// A function that creates a new root directory. This is done if there is no root directory yet.
		func makeRootDirectory() -> Directory {
			let directory = Directory(context: dataController.persistentContainer.viewContext)
			dataController.setNeedsSaved()
			return directory
		}
		
		// Fetch any single directory object
		let request = NSFetchRequest<Directory>(entityName: "Directory")
		request.fetchLimit = 1
		
		do {
			let fetch = try dataController.persistentContainer.viewContext.fetch(request)
			guard var child = fetch.first else {
				// There were no results returned, so make a root directory
				rootDirectory = makeRootDirectory()
				return
			}
			// Recursivley set the child to the parent in order to traverse up the tree until there is no parent. The root has no parent
			while let parent = child.parent {
				child = parent
			}
			rootDirectory = child
		} catch {
			print("Failed to fetch root directory: \(error)")
			rootDirectory = nil
		}
	}
	
	func files(in directories: [Directory]) -> [File] {
		return directories.flatMap { directory -> [File] in
			let directChildren = directory.children.compactMap { $0 as? File }
			let recursiveChildren = files(in: directory.subdirectories)
			return directChildren + recursiveChildren
		}
	}
}
