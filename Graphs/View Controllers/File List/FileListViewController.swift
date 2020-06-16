//
//  FileListViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 5/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class FileListViewController: NSViewController {
	/// The table view.
	@IBOutlet weak var tableView: NSTableView!
	/// The label in the bottom bar of the window. Displays the numebr of files in the directory selection as well as the currently selected files in the table view.
	@IBOutlet weak var itemsSelectedLabel: NSTextField!
	
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	
	@IBOutlet var dateFormatter: DateFormatter!
	@IBOutlet var byteCountFormatter: ByteCountFormatter!
	
	var fileListIsUpdating = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
		// Allows dragging files to the trash can to delete them
		tableView.setDraggingSourceOperationMask([.delete], forLocal: false)
	}
	
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		// Needs to be notified when the directory selection has changed in order to update the files to show
		notificationCenter.addObserver(self,
																	 selector: #selector(filesToShowDidChange(_:)),
																	 name: .filesDisplayedDidChange,
																	 object: nil)
		// Needs to be notified when the file list is being updated on another thread to show the progress indicator
		notificationCenter.addObserver(self,
																	 selector: #selector(fileListStartedWork(_:)),
																	 name: .fileListStartedWork,
																	 object: nil)
		notificationCenter.addObserver(self,
																	 selector: #selector(fileListFinishedWork(_:)),
																	 name: .fileListFinishedWork,
																	 object: nil)
	}
	
	@objc func fileListStartedWork(_ notification: Notification) {
		fileListIsUpdating = true
		tableView.reloadData()
		progressIndicator.startAnimation(self)
	}
	
	@objc func fileListFinishedWork(_ notification: Notification) {
		fileListIsUpdating = false
		tableView.reloadData()
		progressIndicator.stopAnimation(self)
	}
	
	@objc func filesToShowDidChange(_ notification: Notification) {
		if let userInfo = notification.userInfo as? [String: Any] {
			if let oldValue = userInfo[UserInfoKeys.oldValue] as? [File] {
				if let filesToShow = dataController?.filesDisplayed {
					let diff = filesToShow.difference(from: oldValue)
					
					let removalIndicies = diff.compactMap { change -> Int? in
						switch change {
						case .insert(offset: _, element: _, associatedWith: _):
							return nil
						case .remove(offset: let offset, element: _, associatedWith: _):
							return offset
						}
					}
					
					let insertionIndicies = diff.compactMap { change -> Int? in
						switch change {
						case .insert(offset: let offset, element: _, associatedWith: _):
							return offset
						case .remove(offset: _, element: _, associatedWith: _):
							return nil
						}
					}
					
					tableView.beginUpdates()
					tableView.removeRows(at: IndexSet(removalIndicies),
															 withAnimation: .slideDown)
					tableView.insertRows(at: IndexSet(insertionIndicies),
															 withAnimation: .slideDown)
					
					let collectionNameColumnIndex = tableView.column(withIdentifier: .fileCollectionNameColumn)
					// When moving files to a new directory the collection name may change, so reload that column
					tableView.reloadData(forRowIndexes: IndexSet(0..<filesToShow.count), columnIndexes: IndexSet(integer: collectionNameColumnIndex))
					
					tableView.endUpdates()
					selectionDidChange()
					return
				}
			}
		}
		// If the user dictionary didn't include the old collection in the userInfo dictionary then don't animate
		tableView.reloadData()
		// The selection may change so update the row selection label
		selectionDidChange()
	}
	/// Updates the model with a list of the currently selected files as well as updates the bottom bar's label.
	func selectionDidChange() {
		updateSelectionLabel()
		guard let dataController = dataController else { return }
		// Update the selected files, which will send out a notificaiton to update the setter.
		let filesSelected = tableView.selectedRowIndexes
			.map { dataController.filesDisplayed[$0] }
		dataController.filesSelected = filesSelected
	}
	/// Updates the text on the bottom bar's label to indicate how many items are in the selected directories and how many are selected.
	func updateSelectionLabel() {
		let numberOfFiles = tableView.numberOfRows
		let numberOfSelectedFiles = tableView.numberOfSelectedRows
		let numberOfSelectedDirectories = dataController?.selectedDirectories.count ?? 0
		
		if numberOfSelectedDirectories == 0 {
			itemsSelectedLabel.stringValue = "0 directories selected"
			// Further processing is done down below, so just return now for this case
			return
		}
		
		// localize the word "directory" for plurality
		let directoriesText = numberOfSelectedDirectories == 1 ? "directory" : "directories"
		
		// localize the word "file" for plurality
		let filesText = numberOfFiles == 1 ? "file" : "files"
		
		if numberOfSelectedFiles == 0 {
			itemsSelectedLabel.stringValue = "\(numberOfFiles) \(filesText) in \(numberOfSelectedDirectories) \(directoriesText)"
		} else {
			
			itemsSelectedLabel.stringValue = "\(numberOfSelectedFiles) of \(numberOfFiles) files selected in \(directoriesText)"
		}
	}
}

// MARK: Helper Functions
extension FileListViewController {
	var dataController: DataController? {
		return DataController.shared
	}
	
	var context: NSManagedObjectContext? {
		return dataController?.context
	}
	
	func removeSelectedFiles() {
		let files = tableView.selectedRowIndexes.compactMap { index in
			dataController?.filesDisplayed[index]
		}
		remove(files: files)
	}
	
	func remove(files: [File]) {
		guard let dataController = dataController else {
			print("[WARNING] directoryController was nil at FileListViewController.remove(files:rows:).")
			return
		}
		
		files.forEach { file in
			file.parent?.removeFromChildren(file)
			file.parent = nil
			context?.delete(file)
		}
		
		// Get the indicies of the rows that are being removed so we can animate their removal
		let rows = dataController.filesDisplayed.indicies(of: files)
		tableView.removeRows(at: rows, withAnimation: .slideDown)
		// We do not need to call directoryController.updateFilesToShow() becuase we manually manage the change to animate it. If we would also call this function, it would abort the animation.
	}
}

// MARK: Collection Utilities
extension Collection where Element: Hashable, Index == Int {
	// This function was written to find the indicies of m elements in a collection of n elements in O(n+m) time. Calling firstIndex(of:) repeatedly instead is O(n*m)
	func indicies(of elements: [Element]) -> IndexSet {
		let elementSet = Set(elements)
		var iterator = makeIterator()
		var indicies = IndexSet()
		var index = startIndex
		while let element = iterator.next() {
			if elementSet.contains(element) {
				indicies.insert(index)
			}
			index = self.index(after: index)
		}
		
		return indicies
	}
}
