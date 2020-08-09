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
		// When the file list is updating hide the elements
		if fileListIsUpdating { return 0 }
		return dataController?.filesDisplayed.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		guard row < dataController?.filesDisplayed.count ?? 0 else {
			// If the row is greater than the count or the controller is nil, return nil (this should never happen)
			print("[WARNING] FIleListViewController could not find file for the table view at trow \(row).")
			return nil
		}
		return dataController?.filesDisplayed[row]
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
		case .fileDateCreatedColumn:
			cellIdentifier = .fileDateCreatedCell
		case .fileDateModifiedColumn:
			cellIdentifier = .fileDateModifiedCell
		case .fileSizeColumn:
			cellIdentifier = .fileSizeCell
		default:
			return nil
		}
		
		guard let view = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
		
		// We use the column identifier rather than a tag becuase the performance impact is negligable and the column identifiers are more descriptive to aid in debuging
		switch tableColumn.identifier {
		case .fileNameColumn:
			view.textField?.stringValue = file.displayName
		case .fileCollectionNameColumn:
			view.textField?.stringValue = collectionName(forFile: file)
		case .fileDateImportedColumn:
			if let formattedDate = dateFormatter.string(for: file.dateImported) {
				view.textField?.stringValue = formattedDate
			} else {
				view.textField?.stringValue = ""
			}
		case .fileDateCreatedColumn:
			if let formattedDate = dateFormatter.string(for: file.dateCreated) {
				view.textField?.stringValue = formattedDate
			} else {
				view.textField?.stringValue = ""
			}
		case .fileDateModifiedColumn:
			if let formattedDate = dateFormatter.string(for: file.dateModified) {
				view.textField?.stringValue = formattedDate
			} else {
				view.textField?.stringValue = ""
			}
		case .fileSizeColumn:
			if let fileSize = file.fileSize {
				let formattedSize = byteCountFormatter.string(fromByteCount: Int64(fileSize))
				view.textField?.stringValue = formattedSize
			} else {
				view.textField?.stringValue = ""
			}
		default:
			return nil
		}
		
		if let path = file.path {
			view.textField?.setValid(FileManager.default.fileExists(atPath: path.path))
		} else {
			view.textField?.setValid(false)
		}
		
		return view
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		// Update the text at the bottom of the window which displays the number of selected files
		selectionDidChange()
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		guard let sortKeyString = tableView.sortDescriptors.first?.key,
			let sortKey = File.SortKey(rawValue: sortKeyString),
			let ascending = tableView.sortDescriptors.first?.ascending else {
			dataController?.fileSortKey = nil
			return
		}
		
		dataController?.fileSortKey = sortKey
		dataController?.sortFilesAscending = ascending
	}
}

// MARK: Helper Functions
extension FileListViewController {
	func collectionName(forFile file: File) -> String {
		guard let parent = file.parent else {
			// Every file should belong to a directory so this should never happen
			print("[WARNING] File has no parent at FileListViewController.collectionName(forFile:).")
			return ""
		}
		
		if parent == dataController?.rootDirectory {
			// If the parent directory is root, then don't display a name for the collection
			return ""
		} else {
			// Otherwise show the directory's display name
			return parent.displayName
		}
	}
}
