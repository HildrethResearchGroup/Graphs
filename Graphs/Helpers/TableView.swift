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
