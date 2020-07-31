//
//  FileListViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 6/7/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileListViewController {
	/// Deletes the selected files.
	@objc func delete(_ sender: Any?) {
		removeSelectedFiles()
	}
	@objc func deleteRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection()
		removeSelectedFiles()
	}
	@objc func showInFinder(_ sender: Any?) {
		guard let dataController = dataController else { return }
		let selectedPaths = dataController.filesSelected.compactMap { $0.path }
		NSWorkspace.shared.activateFileViewerSelecting(selectedPaths)
	}
	@objc func showInFinderInRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection()
		showInFinder(sender)
	}
}

// MARK: Validations
extension FileListViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		// If the item does not have an action associated with it, then that item should be disabled. Ideally there should not be any items that don't have an action associated with them, but if there are by having them disabled there are two benefits:
		// 1. The user will not be able to click on the item, which they may expect to be doing something.
		// 2. The developer will be more likley to notice that an item is not configured with an action becuase it will be disabled.
		guard let action = item.action else { return false }
		
		switch action {
		case #selector(deleteRow(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			if tableView.selectedRowIndexes.contains(tableView.clickedRow) {
				// Right clicked on the selection, so will be deleting all selected files which is equivelant to the selector delete(_:)
				fallthrough
			} else if tableView.clickedRow >= 0 {
				// Otherwise will be selecting the row that was right clicked -- can always delete that row
				return true
			} else {
				// No selection, so don't validate
				return false
			}
		case #selector(delete(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			return tableView.selectedRowIndexes.count > 0
		case #selector(showInFinderInRow(_:)):
			// Don't allow show in finder if all of the selected files no longer exist
			if tableView.selectedRowIndexes.contains(tableView.clickedRow) {
				// Right clicked on the selection, so will be showing all the files in the selection, which is equivelant to the selector showInFinder(_:)
				fallthrough
			} else if tableView.clickedRow >= 0 {
				// Otherwise will be selecting the row that was right clicked -- make sure that that directory has a valid path
				guard let file = dataController?.filesDisplayed[tableView.clickedRow] else { return false }
				guard let path = file.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			} else {
				// No selection, so don't validate
				return false
			}
		case #selector(showInFinder(_:)):
			// Don't allow show in finder if all of the selected files no longer exist
			guard tableView.selectedRowIndexes.count >= 1 else { return false }
			guard let dataController = dataController else { return false }
			return !dataController.filesSelected.noneSatisfy { file in
				// Returns true if it can open the file
				guard let path = file.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			}
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
