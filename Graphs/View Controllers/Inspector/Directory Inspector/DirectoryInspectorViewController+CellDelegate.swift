//
//  DirectoryInspectorViewController+CellDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension DirectoryInspectorViewController: InspectorTwoTextFieldsCellDelegate {
	func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell) {
		nameTextFieldDidEndEditing(cell.firstTextField)
	}
}

// MARK: Helpers
private extension DirectoryInspectorViewController {
	func nameTextFieldDidEndEditing(_ textField: NSTextField) {
		guard let directory = directory else { return }
		dataController?.rename(directory: directory, to: textField.stringValue)
	}
}
