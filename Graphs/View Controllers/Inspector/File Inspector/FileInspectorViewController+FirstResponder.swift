//
//  FileInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 7/31/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileInspectorViewController {
	/// Shows the selected file in Finder if it exists.
	@objc func showInFinder(_ sender: Any?) {
		guard let path = file?.path else { return }
		NSWorkspace.shared.activateFileViewerSelecting([path])
	}
}

// MARK: Validations
extension FileInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
		case #selector(showInFinder(_:)):
			// If there inspector isn't showing a file (file == nil), or if the file doesn't have a path, then it can't be show in Finder
			guard let path = file?.path else { return false }
			// Only allow showing in Finder if a file exists at the file's given path
			return FileManager.default.fileExists(atPath: path.path)
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
