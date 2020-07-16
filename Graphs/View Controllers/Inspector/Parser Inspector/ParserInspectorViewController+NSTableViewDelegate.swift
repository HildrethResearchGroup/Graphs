//
//  ParserInspectorViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension ParserInspectorViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return dataController?.parsers.count ?? 0
	}
}

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
}

extension ParserInspectorViewController: InspectorTableViewCellDelegate {
	func addButtonPressed(_ cell: InspectorTableViewCell) {
		guard let dataController = dataController else { return }
		dataController.createParser()
		let lastRow = IndexSet(integer: dataController.parsers.count - 1)
		cell.tableView.insertRows(at: lastRow, withAnimation: .slideDown)
	}
	
	func removeButtonPressed(_ cell: InspectorTableViewCell) {
		guard let dataController = dataController else { return }
		let rows = cell.tableView.selectedRowIndexes
		let parsers = rows.map { dataController.parsers[$0] }
		parsers.forEach { dataController.remove(parser: $0) }
		cell.tableView.removeRows(at: rows, withAnimation: .slideDown)
	}
	
	func controlTextDidEndEditing(_ cell: InspectorTableViewCell, textField: NSTextField, at row: Int) {
		guard let dataController = dataController else { return }
		
		if let tokenField = textField as? NSTokenField {
			// Editing the parser's default file types
			let fileTypes = tokenField.stringValue.components(separatedBy: ",")
			dataController.changeDefaultFileTypes(for: dataController.parsers[row],
																						to: fileTypes)
		} else {
			// Editing the parser's name
			dataController.rename(parser: dataController.parsers[row],
														to: textField.stringValue)
		}
	}
}
