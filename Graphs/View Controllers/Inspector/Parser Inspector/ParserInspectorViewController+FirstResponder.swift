//
//  ParserInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 8/8/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension ParserInspectorViewController {
	@objc func exportParser(_ sender: Any?) {
		guard let dataController = dataController else { return }
		guard let tableView = tableView else { return }
		guard tableView.selectedRowIndexes.count == 1 else { return }
		let parser = dataController.parsers[tableView.selectedRowIndexes.first!]
		
		let savePanel = NSSavePanel()
		savePanel.allowedFileTypes = ["gparser"]
		savePanel.canCreateDirectories = true
		savePanel.nameFieldStringValue = parser.name
		savePanel.runModal()
		guard let url = savePanel.url else { return }
		parser.export(to: url)
	}
	
	@objc func importParser(_ sender: Any?) {
		guard let dataController = dataController else { return }
		guard let tableView = tableView else { return }
		
		let openPanel = NSOpenPanel()
		openPanel.allowedFileTypes = ["gparser"]
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.runModal()
		guard let url = openPanel.url else { return }
		let newParser = dataController.createParser()
		newParser.import(from: url)
		tableView.insertRows(at: IndexSet(integer: tableView.numberOfRows), withAnimation: .slideDown)
	}
}

// MARK: Validations
extension ParserInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		return true
	}
}
