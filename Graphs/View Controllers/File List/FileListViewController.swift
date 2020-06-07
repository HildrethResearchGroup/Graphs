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
		guard let directoryController = directoryController else {
			print("[WARNING] directoryController was nil at FileListViewController.remove(files:rows:).")
			return
		}
		
		files.forEach { file in
			file.parent?.removeFromChildren(file)
			file.parent = nil
			context?.delete(file)
		}
		
		// Get the indicies of the rows that are being removed so we can animate their removal
		let rows = directoryController.filesToShow.indicies(of: files)
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
