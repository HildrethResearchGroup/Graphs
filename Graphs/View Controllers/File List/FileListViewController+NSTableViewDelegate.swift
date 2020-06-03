//
//  FileListViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 5/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileListViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return DataController.shared?.directoryController.filesToShow.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		guard row < DataController.shared?.directoryController.filesToShow.count ?? 0 else {
			// If the row is greater than the count or the controller is nil, return nil (this should never happen)
			print("[WARNING] FIleListViewController could not find file for the table view at trow \(row).")
			return nil
		}
		return DataController.shared!.directoryController.filesToShow[row]
	}
}

extension FileListViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn else { return nil }
		guard let file = self.tableView(tableView, objectValueFor: tableColumn, row: row) as? File else { return nil }
		
		let cellIdentifier: NSUserInterfaceItemIdentifier
		
		switch tableColumn.identifier {
		case .fileNameColumn:
			cellIdentifier = .fileNameCell
		case .fileCollectionNameColumn:
			cellIdentifier = .fileCollectionNameCell
		case .fileDateImportedColumn:
			cellIdentifier = .fileDateImportedCell
		default:
			return nil
		}
		
		guard let view = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
		
		switch tableColumn.identifier {
		case .fileNameColumn:
			view.textField?.stringValue = file.displayName
		case .fileCollectionNameColumn:
			view.textField?.stringValue = collectionName(forFile: file)
		case .fileDateImportedColumn:
			// TODO: Add import date
			view.textField?.stringValue = "0/0/0"
		default:
			return nil
		}
		
		return view
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		updateRowSelectionLabel()
	}
}

// MARK: Helper Functions
extension FileListViewController {
	func collectionName(forFile file: File) -> String {
		guard let parent = file.parent else {
			// Every file should belong to a directory so this should never happen
			print("[WARNING] File has no parent.")
			return ""
		}
		
		if parent == DataController.shared?.directoryController.rootDirectory {
			// If the parent directory is root, then don't display a name for the collection
			return ""
		} else {
			// Otherwise show the directory's display name
			return parent.displayName
		}
	}
}
