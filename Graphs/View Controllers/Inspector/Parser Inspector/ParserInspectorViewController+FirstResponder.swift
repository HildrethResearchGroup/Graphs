//
//  ParserInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 8/8/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension ParserInspectorViewController {
	@objc func exportParserRow(_ sender: Any?) {
		guard let tableView = tableView else { return }
		selectClickedRowIfNotInSelection(in: tableView)
		exportSelectedParser()
	}
	
	@objc func exportParser(_ sender: Any?) {
		exportSelectedParser()
	}
	@objc func importParser(_ sender: Any?) {
		guard let dataController = dataController else { return }
		guard let tableView = tableView else { return }
		
		let openPanel = NSOpenPanel()
		openPanel.allowedFileTypes = ["gparser"]
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		guard let window = view.window else { return }
		openPanel.beginSheetModal(for: window) { (response) in
			if response == .OK, let url = openPanel.url {
				let newParser = dataController.createParser()
				newParser.import(from: url)
				tableView.insertRows(at: IndexSet(integer: tableView.numberOfRows), withAnimation: .slideDown)
			}
		}
	}
}

// MARK: Validations
extension ParserInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
		case #selector(exportParserRow(_:)):
			guard let tableView = tableView else { return false }
			guard dataController != nil else { return false }
			// When no item is selected, invalidate the "export" button so that the user doesn't mistakenly think they are exporting an item/items when they are not
			if tableView.selectedRowIndexes.contains(tableView.clickedRow) {
				// Right clicked on the selection, so will be exporting the selected file which is equivelant to the selector exportParser(_:)
				fallthrough
			} else if tableView.clickedRow >= 0 {
				// Otherwise will be selecting the row that was right clicked -- can always delete that row
				return true
			} else {
				// No selection, so don't validate
				return false
			}
		case #selector(exportParser(_:)):
			guard let tableView = tableView else { return false }
			guard dataController != nil else { return false }
			// Only allow exporting one item at a time (because of the save dialog)
			return tableView.numberOfSelectedRows == 1
		case #selector(importParser(_:)):
			guard tableView != nil && dataController != nil else { return false }
			return true
		default:
			return true
		}
	}
}
