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
			// When the selection changes, the file list table needs to be updated. It will respond to this notification
			filesToShow = files(in: selectedDirectories)
			let notification = Notification(name: .directorySelectionChanged)
			NotificationCenter.default.post(notification)
		}
	}
	/// The files in the currently selected directories.
	private(set) var filesToShow: [File] = []
	
	init(dataController: DataController) {
		// The directory controller gets its data from a data controller, so a data controller must be provided to create a directory contoller
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
		// Must register for undo/redo notifications to invalidate any caches
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
	
	/// Returns the files in the given directories and their subdirectories recursivley.
	/// - Parameter directories: The directories to check for files in.
	/// - Returns: The files in the given directories and their subdirectories recursivley.
	func files(in directories: [Directory]) -> [File] {
		return files(in: directories, knownNoDescendents: false)
	}
	
	/// The function used by `files(in:)` but with an added parameter for recursive performance. The wrapper function is used without the parameter because the parameter should always be `true` the first time it is called and `false` when it is beinc called from withinside itself (recursivley). To prevent the user for accidentally passing the wrong value the parameter is removed from the internal interface.
	/// - Parameters:
	///   - directories: The directories  to check for files in.
	///   - knownNoDescendents: `true` if it is known that none of the passed directories are a descendents of eachother, `false` otherwise.
	/// - Returns: The files in the given directories and their subdirectories recursivley.
	private func files(in directories: [Directory], knownNoDescendents: Bool) -> [File] {
		
		let map: (Directory) -> [File] = { directory -> [File] in
			// Add this directories children and its subdirectories' children recursivley
			let directChildren = directory.children.compactMap { $0 as? File }
			// We know that none of the passed directories are descendents of eachother because they all have the same parent.
			let recursiveChildren = self.files(in: directory.subdirectories, knownNoDescendents: true)
			return directChildren + recursiveChildren
		}
		
		if knownNoDescendents {
			return directories
				// No need to filter becuase there are no directories that are descendents of other directories in the given array
				.flatMap(map)
		}
		
		// Contains will be called O(n) times where n is the number of elements in the collection. Without using a set, the algorithm is O(n^2), but by using a set, the algorithm is only O(n).
		let directoriesSet = Set(directories)
		
		return directories
			// Remove directories whose ancestors are in the array of directories
			.filter { !$0.isDescendent(of: directoriesSet) }
			.flatMap(map)
	}
}
