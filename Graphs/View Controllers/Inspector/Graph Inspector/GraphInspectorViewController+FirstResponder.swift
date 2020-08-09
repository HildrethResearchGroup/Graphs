//
//  GraphInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 8/9/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension GraphInspectorViewController {
	@objc func delete(_ sender: Any?) {
		removeSelectedGraphTemplates()
	}
	
	@objc func deleteRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		removeSelectedGraphTemplates()
	}
	
	@objc func importGraphTemplate(_ sender: Any?) {
		addGraphTemplate(sender)
	}
}

// MARK: Validations
extension GraphInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
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
		default:
			return true
		}
	}
}
