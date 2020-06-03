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
	@IBOutlet weak var itemsSelectedLabel: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
	}
	
	func registerObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(directorySelectionDidChange), name: .directorySelectionChanged, object: nil)
		
	}
	
	@objc func directorySelectionDidChange() {
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
