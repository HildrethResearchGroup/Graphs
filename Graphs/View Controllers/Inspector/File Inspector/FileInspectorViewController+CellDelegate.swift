//
//  FileInspectorViewController+CellDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: TwoTextFields
extension FileInspectorViewController: InspectorTwoTextFieldsCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		// Name textField
		if let file = file {
			dataController?.rename(file: file, to: cell.firstTextField.stringValue)
		}
	}
}

// MARK: TwoPopUpButtons
extension FileInspectorViewController: InspectorTwoPopUpButtonsCellDelegate {
	func firstPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell) {
		// Parser popup
		guard let dataController = dataController else { return }
		guard let item = cell.firstPopUpButton.selectedItem else { return }
		switch item.tag {
		case -2:
			// Default for file type
			file?.defaultParserMode = .fileTypeDefault
			file?.parser = nil
		case -1:
			// Default for folder
			file?.defaultParserMode = .folderDefault
			file?.parser = nil
		case 0..<dataController.parsers.count:
			file?.parser = dataController.parsers[item.tag]
		default:
			print("[WARNING] Invalid tag at FileInspectorViewController.firstPopUpButtonDidChange(_:)")
			file?.parser = nil
		}
		dataController.setNeedsSaved()
		
		// This could change the experiment details
		let lastRow = outlineView.numberOfRows - 1
		outlineView.reloadData(forRowIndexes: IndexSet(integer: lastRow),
													 columnIndexes: IndexSet(integer: 0))
		
		NotificationCenter.default.post(name: .graphMayHaveChanged, object: file)
	}
	
	func secondPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell) {
		// Graph template popup
		guard let dataController = dataController else { return }
		guard let item = cell.secondPopUpButton.selectedItem else { return }
		switch item.tag {
		case -1:
			// Default for folder
			file?.graphTemplate = nil
		case 0..<dataController.graphTemplates.count:
			file?.graphTemplate = dataController.graphTemplates[item.tag]
		default:
			print("[WARNING] Invalid tag at FileInspectorViewController.secondPopUpButtonDidChange(_:)")
			file?.graphTemplate = nil
		}
		dataController.setNeedsSaved()
		NotificationCenter.default.post(name: .graphMayHaveChanged, object: file)
	}
}

// MARK: CategoryOption
extension FileInspectorViewController: InspectorCategoryOptionCellDelegate {
	func popUpDidChangeState(_ cell: InspectorCategoryOptionCell) {
		switch cell.popUpButton.selectedTag() {
		case 0:
			// From file
			showingCustomDetails = false
		case 1:
			// Custom
			showingCustomDetails = true
		default:
			print("[WARNING] Invalid tag at FileInspectorViewController.popUpDidChangeState(_:)")
			showingCustomDetails = true
		}
	}
}

// MARK: TextView
extension FileInspectorViewController: InspectorTextViewCellDelegate {
	func textDidEndEditing(_ cell: InspectorTextViewCell) {
		// Only can edit custom details
		if showingCustomDetails {
			file?.customDetails = cell.textView.string
		}
	}
}
