//
//  SidebarViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 5/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: Responder Actions
extension SidebarViewController {
	/// Deletes the selected directories in the sidebar.
	@objc func delete(_ sender: Any?) {
		removeSelectedDirectories(sender)
	}
	/// Deletes the clicked directory or selection of directories.
	@objc func deleteRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection()
		
		removeSelectedDirectories(sender)
	}
	/// Creates a new directory.
	@objc func newDirectory(_ sender: Any?) {
		addDirectory(sender)
	}
	/// Creates a new directory as a child of the clicked row.
	@objc func newDirectoryRow(_ sender: Any?) {
		selectClickedRow()
		addDirectory(sender)
	}
	/// Asks the user to import new items.
	@objc func importItems(_ sender: Any?) {
		let dropDirectory: Directory? = {
			guard let lastSelectedRow = sidebar.selectedRowIndexes.last else { return dataController?.rootDirectory }
			let itemAtRow = sidebar.item(atRow: lastSelectedRow)
			return directoryFromItem(itemAtRow)
		}()
		
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = true
		openPanel.canChooseDirectories = true
		// If the rootDirectory is the import location (nil will result in the rootDirecotry being the drop location as well) then files cannot be selected becuase files cannot be in the root directory.
		openPanel.canChooseFiles = dropDirectory != nil && dropDirectory != rootDirectory
		
		openPanel.accessoryView = importAccessoryView
		
		openPanel.beginSheetModal(for: view.window!) { (response) in
			if response == .OK {
				let includeSubdirectories = self.importSubdirectoriesCheckbox.state == .on
				self.importURLs(openPanel.urls,
												dropDirectory: dropDirectory,
												childIndex: nil,
												includeSubdirectories: includeSubdirectories)
			}
		}
	}
	/// Imports items into the clicked directory.
	@objc func importItemsRow(_ sender: Any?) {
		selectClickedRow()
		importItems(sender)
	}
	/// Shows the selected directories in Finder.
	@objc func showInFinder(_ sender: Any?) {
		guard let dataController = dataController else { return }
		let selectedPaths = dataController.selectedDirectories.compactMap { $0.path }
		NSWorkspace.shared.activateFileViewerSelecting(selectedPaths)
	}
	/// Shows the clicked directory or selection of directories in Finder.
	@objc func showInFinderRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection()
		showInFinder(sender)
	}
}

// MARK: Validations
extension SidebarViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		// If the item does not have an action associated with it, then that item should be disabled. Ideally there should not be any items that don't have an action associated with them, but if there are by having them disabled there are two benefits:
		// 1. The user will not be able to click on the item, which they may expect to be doing something.
		// 2. The developer will be more likley to notice that an item is not configured with an action becuase it will be disabled.
		guard let action = item.action else { return false }
		
		switch action {
		case #selector(deleteRow(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			return !sidebar.hasEmptyClickRowSelection
		case #selector(delete(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			return !sidebar.hasEmptyRowSelection
		case #selector(importItems(_:)):
			// Don't allow importing items when multiple items are selected becuase it may be ambigious to the user where the items are being imported to. An empty selection is allowed and will have items be imported at the root directory.
			return sidebar.selectedRowIndexes.count <= 1
		case #selector(showInFinderRow(_:)):
			// Don't allow show in finder if all of the selected directories no longer exist
			if sidebar.selectedRowIndexes.contains(sidebar.clickedRow) {
				// Right clicked on the selection, so will be showing all the directories in the selection, which is equivelant to the selector showInFinder(_:)
				fallthrough
			} else if sidebar.clickedRow >= 0 {
				// Otherwise will be selecting the row that was right clicked -- make sure that that directory has a valid path
				guard let directory = sidebar.item(atRow: sidebar.clickedRow) as? Directory else { return false }
				guard let path = directory.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			} else {
				// No selection, so don't validate
				return false
			}
		case #selector(showInFinder(_:)):
			// Don't allow show in finder if all of the selected directories no longer exist
			guard !sidebar.hasEmptyRowSelection else { return false }
			guard let dataController = dataController else { return false }
			return !dataController.selectedDirectories.noneSatisfy { directory in
				// Returns true if it can open the file
				guard let path = directory.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			}
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
