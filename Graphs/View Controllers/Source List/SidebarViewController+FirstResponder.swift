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
	
	/// Creates a new directory.
	@objc func newDirectory(_ sender: Any?) {
		addDirectory(sender)
	}
	
	/// Asks the user to import new items.
	@objc func importItems(_ sender: Any?) {
		let dropDirectory: Directory? = {
			guard let lastSelectedRow = sidebar.selectedRowIndexes.last else { return nil }
			let itemAtRow = sidebar.item(atRow: lastSelectedRow)
			return directoryFromItem(itemAtRow)
		}()
		
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = true
		openPanel.canChooseDirectories = true
		// If the rootDirectory is the import location (nil will result in the rootDirecotry being the drop location as well) then files cannot be selected becuase files cannot be in the root directory.
		openPanel.canChooseFiles = dropDirectory != nil && dropDirectory != rootDirectory
		
		let response = openPanel.runModal()
		if response == .OK {
			importURLs(openPanel.urls, dropDirectory: dropDirectory, childIndex: nil)
		}
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
		case #selector(delete(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			return sidebar.selectedRowIndexes.count > 0
		case #selector(importItems(_:)):
			// Don't allow importing items when multiple items are selected becuase it may be ambigious to the user where the items are being imported to. An empty selection is allowed and will have items be imported at the root directory.
			return sidebar.selectedRowIndexes.count <= 1
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
