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
																	 selector: #selector(filesToShowDidChange),
																	 name: .filesToShowChanged,
																	 object: nil)
	}
	
	@objc func filesToShowDidChange() {
		// When the sidebar's selection of directories change, update the table view
		tableView.reloadData()
		itemsSelectedLabel.integerValue = tableView.numberOfRows
		// The selection may change so update the row selection label
		updateRowSelectionLabel()
	}
	
	/// Updates the text on the bottom bar's label to indicate how many items are in the selected directories and how many are selected
	func updateRowSelectionLabel() {
		let numberOfFiles = tableView.numberOfRows
		let numberOfSelectedFiles = tableView.numberOfSelectedRows
		let numberOfSelectedDirectories = DataController.shared?.directoryController.selectedDirectories.count ?? 0
		
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
	
	var directoryController: DirectoryController? {
		return dataController?.directoryController
	}
	
	var context: NSManagedObjectContext? {
		return dataController?.persistentContainer.viewContext
	}
	
	func removeSelectedFiles() {
		let files = tableView.selectedRowIndexes.compactMap { index in
			directoryController?.filesToShow[index]
		}
		remove(files: files)
	}
	
	func remove(files: [File]) {
		files.forEach { file in
			file.parent?.removeFromChildren(file)
			file.parent = nil
			context?.delete(file)
		}
		
		directoryController?.updateFilesToShow()
	}
}
