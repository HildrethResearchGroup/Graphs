//
//  DataInspectorViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension DataInspectorViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		guard let parsedFile = parsedFile else { return 0 }
		// The table view header can only be one row long, so display the other headers at the top of the data list. If there is no header, then there should be 0 row allocated (not -1) hence the max()
		return max(parsedFile.header.count - 1, 0) + parsedFile.data.count
	}
	
	func cells(forRow row: Int, column: Int) -> String {
		func getRow() -> [String] {
			guard let parsedFile = parsedFile else { return [] }
			let headerRows = parsedFile.header.count - 1
			if headerRows > 0 {
				if (0..<headerRows).contains(row) {
					// Displaying a header row
					return parsedFile.header[row + 1]
				} else {
					return parsedFile.data[row - headerRows]
				}
			}
			else {
				return parsedFile.data[row]
			}
		}
		
		let row = getRow()
		
		if column < row.count {
			return row[column]
		} else {
			return ""
		}
	}
}

extension DataInspectorViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn else { return nil }
		guard let column = tableView.tableColumns.firstIndex(of: tableColumn) else { return nil }
		let cell = tableView.makeView(withIdentifier: .dataInspectorTableCell, owner: self) as? NSTableCellView
		guard let parsedFile = parsedFile else { return cell }
		
		cell?.textField?.stringValue = cells(forRow: row, column: column)
		let headerRows = parsedFile.header.count - 1
		if headerRows > 0 {
			if (0..<headerRows).contains(row) {
				// Change the background color of header rows
				cell?.textField?.textColor = .headerTextColor
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
		guard let parsedFile = parsedFile else { return }
		let headerRows = parsedFile.header.count - 1
		if headerRows > 0 {
			if (0..<headerRows).contains(row) {
				// Change the background color of header rows
				rowView.backgroundColor = .windowBackgroundColor
			}
		}
	}
}
