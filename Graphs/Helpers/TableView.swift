//
//  TableView.swift
//  Graphs
//
//  Created by Connor Barnes on 8/8/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTableViewDelegate {
	func selectClickedRowIfNotInSelection(in tableView: NSTableView) {
		if tableView.clickedRow >= 0 && !tableView.selectedRowIndexes.contains(tableView.clickedRow) {
			// Right clicking on an unselected row, so delete that row
			tableView.selectRowIndexes(IndexSet(integer: tableView.clickedRow),
																 byExtendingSelection: false)
		}
	}
}
