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
			let notification = Notification(name: .directorySelectionChanged)
			NotificationCenter.default.post(notification)
		}
	}
	/// The files in the currently selected directories.
	private(set) var filesToShow: [File] = []
	
	init(dataController: DataController) {
		self.dataController = dataController
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
		directories.flatMap { directory -> [File] in
			let subdirectories = directory.subdirectories
			
			// This is really inefficient and should be changed
			// Delete all of the files and readd them based off the current directory
			
			let cachedSubFiles = directory.children.compactMap { $0 as? File }
			
			cachedSubFiles.forEach { subfile in
				directory.removeFromChildren(subfile)
				subfile.parent = nil
				dataController.persistentContainer.viewContext.delete(subfile)
			}
			
			// Determine the files based off the directory's disk contents
			
			var files: [File] = []
			
			if let directoryPath = directory.path {
				do {
					let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey], options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles])
					
					let directoryFiles = contents.filter { (url) -> Bool in
						do {
							let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
							guard let isDirectory = resourceValues.isDirectory, let isPackage = resourceValues.isPackage else {
								// Don't include items which were not able to be determined as a direcotyr or a package
								print("[WARNING] Could not identify if a file was a directory or package at url: \(url.absoluteString)")
								return false
							}
							// Direcories and packages are not counted as files
							return !(isDirectory || isPackage)
						} catch {
							// Don't include items for which their resource values could not be obtained
							print("[WARNING] Could not obtain resource values at url: \(url.absoluteString)")
							return false
						}
					}.map { fileURL -> File in
						let file = File(context: self.dataController.persistentContainer.viewContext)
						file.path = fileURL
						file.parent = directory
						directory.addToChildren(file)
						file.parent = directory
						return file
					}
					
					files += directoryFiles
					
				} catch {
					
				}
			}
			
			
			
			
		}
	}
}
