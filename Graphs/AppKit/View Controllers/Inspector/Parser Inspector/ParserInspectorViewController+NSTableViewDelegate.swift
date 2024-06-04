//
//  ParserInspectorViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: NSTableViewDataSource
extension ParserInspectorViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return dataController?.parsers.count ?? 0
	}
}

// MARK: NSTableViewDelegate
extension ParserInspectorViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn else {
			print("[WARNING] No column specified at ParserInspectorViewController.tableView(_:viewFor:row:)")
			return nil
		}
		
		guard let parser = dataController?.parsers[row] else {
			print("[WARNING] Data controller was nil at ParserInspectorViewController.tableView(_:viewFor:row:)")
			return nil
		}
		
		switch tableColumn.identifier {
		case .parserNameColumn:
			let view = tableView.makeView(withIdentifier: .parserNameCell, owner: self) as? NSTableCellView
			view?.textField?.stringValue = parser.name
			return view
		case .parserDefaultsColumn:
			let view = tableView.makeView(withIdentifier: .parserDefaultsCell, owner: self) as? ParserFileTypesCell
			view?.tokenField?.stringValue = parser.defaultForFileTypes.joined(separator: ", ")
			return view
		default:
			print("[WARNING] Unknown column identifier \(String(describing: tableColumn.identifier)) in ParserInspectorViewController.")
			return nil
		}
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		guard let dataController = dataController else { return }
		guard let tableView = notification.object as? NSTableView else {
			print("[WARNING] Could not find tableview for tableViewSelectionDidChange notification in ParserInspectorViewController")
			parser = nil
			return
		}
		if tableView.selectedRowIndexes.count == 1 {
			parser = dataController.parsers[tableView.selectedRow]
		} else {
			// Either 0 or multiple selected parsers, so don't allow editing
			parser = nil
		}
	}
}
