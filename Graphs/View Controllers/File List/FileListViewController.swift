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
		updateRowSelectionLabel()
	}
	
	/// Updates the text on the bottom bar's label to indicate how many items are in the selected directories and how many are selected
	func updateRowSelectionLabel() {
		let numberOfItems = tableView.numberOfRows
		let selectionCount = tableView.numberOfSelectedRows
		let numberOfSelectedDirectories = DataController.shared?.directoryController.selectedDirectories.count ?? 0
		
		if numberOfSelectedDirectories == 0 {
			itemsSelectedLabel.stringValue = "0 directories selected"
			return
		}
		
		let directoryText: String = {
			if numberOfSelectedDirectories == 1 {
				return "in 1 directory"
			} else {
				return "in \(numberOfSelectedDirectories) directories"
			}
		}()
		
		let filesText: String = {
			if numberOfItems == 1 {
				return "1 file "
			} else {
				return "\(numberOfItems) files "
			}
		}()
		
		if selectionCount == 0 {
			itemsSelectedLabel.stringValue = filesText + directoryText
		} else {
			
			itemsSelectedLabel.stringValue = "\(selectionCount) of " + filesText + "selected " + directoryText
		}
	}
}
