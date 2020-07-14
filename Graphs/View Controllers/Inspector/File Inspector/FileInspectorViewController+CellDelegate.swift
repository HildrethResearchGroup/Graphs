//
//  FileInspectorViewController+CellDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileInspectorViewController: InspectorTwoTextFieldsCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		nameTextFieldDidEndEditing(cell.firstTextField)
	}
}

// MARK: Helpers
extension FileInspectorViewController {
	func nameTextFieldDidEndEditing(_ textField: NSTextField) {
		if let file = file {
			dataController?.rename(file: file, to: textField.stringValue)
		}
	}
}
