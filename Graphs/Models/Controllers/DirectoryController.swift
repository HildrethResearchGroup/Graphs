//
//  DirectoryController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/25/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

/// A class that manages the directories for the app. Use this class to interact with the app's directories.
class DirectoryController {
	/// The data controller which controlls the Core Data store.
	private unowned let dataController: DataController
	/// The root directory. All directories are decendents of this directory.
	private(set) var rootDirectory: Directory?
	/// The currently selected directories.
	var selectedDirectories: [Directory] = [] {
		didSet {
			dataController.updateFilesDisplayed(animate: false)
			NotificationCenter.default.post(name: .directoriesSelectedDidChange,
																			object: self)
		}
	}
	/// Creates a directory controller from a data controller.
	/// - Parameter dataController: The data controller to use.
	init(dataController: DataController) {
		// The directory controller gets its data from a data controller, so a data controller must be provided to create a directory contoller
		self.dataController = dataController
	}
}

// MARK: Helpers
extension DirectoryController {
	/// The Core Data context.
	private var context: NSManagedObjectContext {
		return dataController.context
	}
	
	/// Adds a file or directory to the given directory.
	/// - Parameters:
	///   - parent: The directory to add the item into.
	///   - url: The url of the item to addd.
	///   - index: The index to insert the item at in `parent`. If `nil`, the item is appended.
	///   - animate: If `true` the insertion should be animated, otherwise `false`.
	///   - includeSubdirectories: If `true` then subdirectories in the selected folder should also be imported, otherwise `false`.
	private func addFileSystemObject(in parent: Directory, at url: URL, index: Int? = nil, animate: Bool = false, includeSubdirectories: Bool) {
		if url.isFolder {
			// The item being added is a folder (directory)
			let directory = Directory(context: context)
			directory.path = url
			directory.collapsed = true
			if let index = index {
				parent.insertIntoChildren(directory, at: index)
			} else {
				// Index should only be nil for adding files not folders, but if it is nil just add the directory to the end of the set of children
				parent.addToChildren(directory)
			}
			
			// Add all of the directory's contents
			do {
				let fileURLS = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
				if includeSubdirectories {
					fileURLS.forEach { url in
						addFileSystemObject(in: directory, at: url, includeSubdirectories: true)
					}
				} else {
					// If not including subdirectories, filter out subfolders
					fileURLS.filter { !$0.isFolder }
						.forEach { url in
						addFileSystemObject(in: directory,
																at: url,
																includeSubdirectories: true)
					}
				}
			} catch {
				// Error reading directories content
				print("[WARNING] Failed to read directory content: \(error)")
			}
			
		} else {
			// The item being added is just a file
			let file = File(context: context)
			file.path = url
			file.dateImported = Date()
			parent.addToChildren(file)
		}
	}
}

// MARK: Interface
extension DirectoryController {
	/// Fetches the root directory if it exists. Otherwise creates the root directory.
	/// - Returns: The (possibly newly created) root directory.
	func loadRootDirectory() {
		/// A function that creates a new root directory. This is done if there is no root directory yet.
		func makeRootDirectory() -> Directory {
			let directory = Directory(context: context)
			dataController.setNeedsSaved()
			return directory
		}
		// Fetch any single directory object
		let request = NSFetchRequest<Directory>(entityName: "Directory")
		request.fetchLimit = 1
		
		do {
			let fetch = try context.fetch(request)
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
	/// Creates a new subdirectory in the given directory.
	/// - Parameter parent: The directory to create a subdirectory inside of.
	/// - Returns: The new directory that was created.
	@discardableResult
	func createSubdirectory(in parent: Directory) -> Directory {
		let subdirectory = Directory(context: context)
		parent.addToChildren(subdirectory)
		parent.collapsed = false
		dataController.setNeedsSaved()
		return subdirectory
	}
	/// Removes the given directory.
	/// - Parameter directory: The directory to remove.
	func remove(directory: Directory) {
		if let parent = directory.parent {
			directory.parent = nil
			parent.removeFromChildren(directory)
		}
		dataController.setNeedsSaved()
	}
	/// Renames a directory.
	/// - Parameters:
	///   - directory: The directory to rename.
	///   - newName: The new name of the directory.
	func rename(directory: Directory, to newName: String?) {
		directory.customDisplayName = newName
		dataController.setNeedsSaved()
		NotificationCenter.default.post(name: .directoryRenamed, object: directory)
	}
	/// Imports files and/or directories from the given urls into the given directory.
	/// - Parameters:
	///   - urls: The urls of the files and/or directories to add.
	///   - dropDirectory: The directory to add the files and/or directories to.
	///   - childIndex: The index of the child inside the directory that files are being added at.
	///   - includeSubdirectories: Wheather or not to include subdirectories of the selection.
	func importURLs(_ urls: [URL], to dropDirectory: Directory, childIndex: Int, includeSubdirectories: Bool) {
		// Don't process if there are no URL's
		guard !urls.isEmpty else { return }
		// addFileSystemObject inserts the directories in the ordered set at the given index. Inserting objects one at a time at a given index will result in it being reversed, so reverse before iterating
		urls.reversed().forEach { url in
			addFileSystemObject(in: dropDirectory,
													at: url, index: childIndex,
													animate: true,
													includeSubdirectories: includeSubdirectories)
		}
	}
}
