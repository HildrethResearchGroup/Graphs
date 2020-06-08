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
}

// MARK: Validations
extension FileListViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		// If the item does not have an action associated with it, then that item should be disabled. Ideally there should not be any items that don't have an action associated with them, but if there are by having them disabled there are two benefits:
		// 1. The user will not be able to click on the item, which they may expect to be doing something.
		// 2. The developer will be more likley to notice that an item is not configured with an action becuase it will be disabled.
		guard let action = item.action else { return false }
		
		switch action {
		case #selector(delete(_:)):
			// When no item is selected, invalidate the "delete" button so that the user doesn't mistakenly think they are deleting an item/items when they are not
			return tableView.selectedRowIndexes.count > 0
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
