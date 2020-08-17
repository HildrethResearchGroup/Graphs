//
//  TableView.swift
//  Graphs
//
//  Created by Connor Barnes on 8/8/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTableViewDelegate {
	/// Selects the row that was just clicked if it is not in the current selection. Otherwise the selection remains unchanged.
	/// - Parameter tableView: The table view to update the selection of.
	func selectClickedRowIfNotInSelection(in tableView: NSTableView) {
		if tableView.clickedRow >= 0 && !tableView.selectedRowIndexes.contains(tableView.clickedRow) {
			// Right clicking on an unselected row, so select that row only instead
			tableView.selectRowIndexes(IndexSet(integer: tableView.clickedRow),
																 byExtendingSelection: false)
		}
	}
}

extension NSTableView {
	/// `true` if the table view has no selected rows, otherwise `false`.
	var hasEmptyRowSelection: Bool {
		return selectedRowIndexes.count == 0
	}
	/// `true` if the table view has no selected rows and the user has not just clicked on a row, otherwise `false`.
	var hasEmptyClickRowSelection: Bool {
		if selectedRowIndexes.contains(clickedRow) {
			// Right clicked on the selection
			return hasEmptyRowSelection
		} else if clickedRow >= 0 {
			// Otherwise will be selecting the row that was right clicked
			return false
		} else {
			// No selection
			return true
		}
	}
}
