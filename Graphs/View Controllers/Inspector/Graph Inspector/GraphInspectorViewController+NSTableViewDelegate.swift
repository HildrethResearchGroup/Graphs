//
//  GraphInspectorViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension GraphInspectorViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		guard let dataController = dataController else { return 0 }
		return dataController.graphTemplates.count
	}
}

extension GraphInspectorViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let template = dataController?.graphTemplates[row] else { return nil }
		
		let view = tableView.makeView(withIdentifier: .graphTemplateNameCell,
																	owner: self) as? NSTableCellView
		
		view?.textField?.stringValue = template.name
		
		return view
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		updateGraph()
	}
}

extension GraphInspectorViewController: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ notification: Notification) {
		guard let textField = textField(for: notification) else { return }
		let row = tableView.row(for: textField)
		guard row > 0 else { return }
		guard let template = dataController?.graphTemplates[row] else { return }
		dataController?.rename(graphTemplate: template, to: textField.stringValue)
	}
}
