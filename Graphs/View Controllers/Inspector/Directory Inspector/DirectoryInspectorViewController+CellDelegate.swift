//
//  DirectoryInspectorViewController+CellDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: TwoTextFieldsCell
extension DirectoryInspectorViewController: InspectorTwoTextFieldsCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		guard let directory = directory else { return }
		dataController?.rename(directory: directory, to: cell.textField?.stringValue)
	}
}

// MARK: TwoPopUpButtonsCell
extension DirectoryInspectorViewController: InspectorTwoPopUpButtonsCellDelegate {
	func firstPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell) {
		// Parser popup
		guard let dataController = dataController else { return }
		guard let item = cell.firstPopUpButton.selectedItem else { return }
		switch item.tag {
		case -1:
			// Default for folder
			directory?.parser = nil
		case 0..<dataController.parsers.count:
			directory?.parser = dataController.parsers[item.tag]
		default:
			print("[WARNING] Invalid tag at DirectoryInspectorViewController.firstPopUpButtonDidChange(_:)")
			directory?.parser = nil
			break
		}
		dataController.setNeedsSaved()
	}
	
	func secondPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell) {
		// Graph template popup
		guard let dataController = dataController else { return }
		guard let item = cell.secondPopUpButton.selectedItem else { return }
		switch item.tag {
		case -1:
			// Default for folder
			directory?.graphTemplate = nil
		case 0..<dataController.graphTemplates.count:
			directory?.graphTemplate = dataController.graphTemplates[item.tag]
		default:
			print("[WARNING] Invalid tag at DirectoryInspectorViewController.secondPopUpButtonDidChange(_:)")
			directory?.graphTemplate = nil
			break
		}
		dataController.setNeedsSaved()
	}
}
