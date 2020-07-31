//
//  DirectoryInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 7/31/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension DirectoryInspectorViewController {
	/// Shows the selected directory in Finder if it exists.
	@objc func showInFinder(_ sender: Any?) {
		guard let path = directory?.path else { return }
		NSWorkspace.shared.activateFileViewerSelecting([path])
	}
}

extension DirectoryInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
		case #selector(showInFinder(_:)):
			// If there inspector isn't showing a directory (directory == nil), or if the directory doesn't have a path, then it can't be show in Finder
			guard let path = directory?.path else { return false }
			// Only allow showing in Finder if a directory exists at the directory's given path
			return FileManager.default.fileExists(atPath: path.path)
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
