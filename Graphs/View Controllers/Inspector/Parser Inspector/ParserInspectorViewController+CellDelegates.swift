//
//  ParserInspectorViewController+CellDelegates.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: TableViewCell
extension ParserInspectorViewController: InspectorTableViewCellDelegate {
	func addButtonPressed(_ cell: InspectorTableViewCell) {
		addParser(in: cell.tableView)
	}
	
	func removeButtonPressed(_ cell: InspectorTableViewCell) {
		deleteSelectedRows(in: cell.tableView)
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

// MARK: CategoryCheckBoxCell
extension ParserInspectorViewController: InspectorCategoryCheckBoxCellDelegate {
	func checkBoxDidChangeState(_ cell: InspectorCategoryCheckBoxCell) {
		switch cell.textField!.stringValue {
		case "Experiment Details":
			// Experiment details
			parser?.hasExperimentDetails = cell.checkBox.state == .on
			if cell.checkBox.state == .off {
				// Remove defaults
				parser?.experimentDetailsStart = nil
				parser?.experimentDetailsEnd = nil
			}
			dataController?.setNeedsSaved()
			reloadData()
		case "Header":
			// Header
			parser?.hasHeader = cell.checkBox.state == .on
			if cell.checkBox.state == .off {
				// Remove defaults
				parser?.headerStart = nil
				parser?.headerEnd = nil
			}
			dataController?.setNeedsSaved()
			reloadData()
		default:
			print("[WARNING] Expected a tag of 1 or 2 for InspectorCategoryCheckBoxCell, but found \(cell.tag) instead.")
		}
	}
}

// MARK: TwoTextFieldsCell
extension ParserInspectorViewController: InspectorTwoTextFieldsCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		// Experiment details start line
		parser?.experimentDetailsStart = cell.firstTextField.integerValue
		dataController?.setNeedsSaved()
		reloadData()
	}
	
	func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		// Experiment details end line
		parser?.experimentDetailsEnd = cell.secondTextField.integerValue
		dataController?.setNeedsSaved()
		reloadData()
	}
}

// MARK: TwoTextFieldsOnePopUpButtonCell
extension ParserInspectorViewController: InspectorTwoTextFieldsOnePopUpButtonCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell) {
		// Header start line
		parser?.headerStart = cell.firstTextField.integerValue
		dataController?.setNeedsSaved()
		reloadData()
	}
	
	func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell) {
		// Header end line
		parser?.headerEnd = cell.secondTextField.integerValue
		dataController?.setNeedsSaved()
		reloadData()
	}
	
	func popUpButtonDidChange(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell) {
		// Header separator
		guard let separator = Parser.Separator(rawValue: cell.popUpButton.selectedItem?.title ?? "") else {
			print("[WARNING] Unknown separator \(cell.popUpButton.selectedItem?.title ?? "nil")")
			return
		}
		parser?.headerSeparator = separator
		dataController?.setNeedsSaved()
		reloadData()
	}
}

// MARK: OneTextFieldOnePopUpButtonOneCheckBoxCell
extension ParserInspectorViewController: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCellDelegate {
	func textFieldDidEndEditing(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell) {
		// Data start line
		parser?.dataStart = cell.textField!.integerValue
		dataController?.setNeedsSaved()
		reloadData()
	}
	
	func popUpButtonDidChange(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell) {
		// Data separator
		guard let separator = Parser.Separator(rawValue: cell.popUpButton.selectedItem?.title ?? "") else {
			print("[WARNING] Unknown separator \(cell.popUpButton.selectedItem?.title ?? "nil")")
			return
		}
		parser?.dataSeparator = separator
		dataController?.setNeedsSaved()
		reloadData()
	}
	
	func checkBoxDidChangeState(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell) {
		// Footer check box
		parser?.hasFooter = cell.checkBox.state == .on
		dataController?.setNeedsSaved()
		reloadData()
	}
}
