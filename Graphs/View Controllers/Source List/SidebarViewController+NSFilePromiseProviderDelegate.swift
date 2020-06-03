//
//  SidebarViewController+NSFilePromiseProvider.swift
//  Graphs
//
//  Created by Connor Barnes on 5/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension SidebarViewController: NSFilePromiseProviderDelegate {
	func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
		if let dragURL = DirectoryPasteboardWriter.urlFromFilePromiseProvider(filePromiseProvider) {
			// Determine the title from the URL
			return dragURL.lastPathComponent
		} else {
			if let dragName = nameFromFilePromiseProvider(filePromiseProvider) {
				// Use the name for the title
				return dragName
			}
		}
		
		// Default to using "Untitled" for the file.
		return "Untitled"
	}
	
	func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
		
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.filePromiseProvider(_:writePromiseTo:completionHandler:")
	}
	
	func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
		return workQueue
	}
}

// MARK: Utilities
extension SidebarViewController {
	/// Returns the name for a given file promise provider.
	/// - Parameter filePromiseProvider: The file promise provider to determine the name from.
	/// - Returns: The name or `nil` if it cannot determine one.
	private func nameFromFilePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider) -> String? {
		let userInfo = filePromiseProvider.userInfo as? [String: Any]
		return userInfo?[DirectoryPasteboardWriter.UserInfoKeys.name] as? String
	}
}
