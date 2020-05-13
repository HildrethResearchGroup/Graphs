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
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.filePromiseProvider(_:fileNameForType:)")
		return ""
	}
	
	func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.filePromiseProvider(_:writePromiseTo:completionHandler:")
	}
	
	func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
		return workQueue
	}
}
