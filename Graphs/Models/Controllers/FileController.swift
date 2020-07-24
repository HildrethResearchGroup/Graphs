//
//  FileController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

class FileController {
	/// The data controller which controls the Core Data store.
	private unowned let dataController: DataController
	/// The background thread to run work on.
	// The QOS is user initiated becuase the user will have to wait while these operations perform.
	private var workQueue = DispatchQueue(label: "directoryControllerWork",
																				qos: .userInitiated)
	/// The cache that stores sorted versions of the file list.
	var sortCache: SortCache!
	/// The current sort key for the file list.
	var sortKey: File.SortKey? {
		didSet {
			sortCache.sortFiles()
		}
	}
	/// The direction of sorting for file list.
	var sortAscending = true {
		didSet {
			sortCache.sortFiles()
		}
	}
	/// The files in the currently selected directories.
	var filesToShow: [File] = []
	/// The currently selected files
	var filesSelected: [File] = [] {
		didSet {
			NotificationCenter.default.post(name: .filesSelectedDidChange,
																			object: self)
		}
	}
	/// Creates a file controller from a data controller.
	/// - Parameter dataController: The data controller to use.
	init(dataController: DataController) {
		self.dataController = dataController
		sortCache = SortCache(fileController: self)
	}
}

// MARK: Helpers
extension FileController {
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
		// Remove directories whose ancestors are in the array of directories
		return directories
			.filter { !$0.isDescendent(of: directoriesSet) }
			.flatMap(map)
	}
	/// Called when work is about to be performed on the background thread. This will make sure that a progress indicator is showed in the UI.
	private func beginWork() {
		NotificationCenter.default.post(name: .fileListStartedWork, object: nil)
	}
	/// Called when work has finished on the background thread. This will refresh the tableview.
	private func endWork() {
		NotificationCenter.default.post(name: .fileListFinishedWork, object: nil)
	}
}

// MARK: Interface
extension FileController {
	/// Updates the files that should be shown based off the directory selection.
	/// - Parameter animate: If `true` the changes will be animated in the table view.
	func updateFilesToShow(animate: Bool) {
		var notification = Notification(name: .filesDisplayedDidChange)
		invalidateSortCache()
		// Don't allow animating if sorting. The background thread interferes with the animation.
		if animate && sortKey == nil {
			// Pass the old files so we can perform a diff on the collection to determine which animations need to be performed
			let oldFilesToShow = filesToShow
			let userInfo = [UserInfoKeys.oldValue: oldFilesToShow]
			notification.userInfo = userInfo
		}
		
		filesToShow = files(in: dataController.selectedDirectories)
		// Don't notify becuase we handle the notificaiton in this function. We cannot rely on sortFiles(notify:) to post the notification because we have custom userInfo that we may need to set in this function
		sortCache.sortFiles(notify: false)
		// When the selection changes, the file list table needs to be updated. It will respond to this notification
		NotificationCenter.default.post(notification)
	}
	/// Performs the given task on the controller's background thread, and  calls the completion handler. The completion takes a `Bool` which is `false` if the work closure threw, otherwise `true`.
	///
	/// A completion notification is sent only if the `work` closure does not throw.
	/// - Parameter work: The work to perform.
	func performBackgroundWork(_ work: @escaping () throws -> (), completion: @escaping (Bool) -> () = { _ in }) {
		beginWork()
		let currentQueue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
		workQueue.async {
			do {
				try work()
				currentQueue.async {
					completion(true)
					self.endWork()
				}
			} catch {
				completion(false)
			}
		}
	}
	/// Called when the items in the directory have changed and any cached sorts are now invalid.
	func invalidateSortCache() {
		// Without aborting background sorting, we will have to wait for the current (now void) sort to complete
		sortCache.abortBackgroundSort()
		// Make a new cache becuase the current one is now invalid
		sortCache = SortCache(fileController: self)
		
		NotificationCenter.default.post(name: .fileListFinishedWork, object: nil)
	}
	/// Returns the files in the given directories and their subdirectories recursivley.
	/// - Parameter directories: The directories to check for files in.
	/// - Returns: The files in the given directories and their subdirectories recursivley.
	func files(in directories: [Directory]) -> [File] {
		return files(in: directories, knownNoDescendents: false)
	}
	/// Renames the given file.
	/// - Parameters:
	///   - file: The file to rename.
	///   - newName: The new name of the file.
	func rename(file: File, to newName: String?) {
		file.customDisplayName = newName
		dataController.setNeedsSaved()
		NotificationCenter.default.post(name: .fileRenamed, object: file)
		updateFilesToShow(animate: true)
	}
}
