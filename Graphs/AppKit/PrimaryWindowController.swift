//
//  PrimaryWindowController.swift
//  Graphs
//
//  Created by Connor Barnes on 5/31/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// A custom window controller is defined to override the undo manager with the Core Data undo manager.
/// A window controller which controlls the primary window in the app.
class PrimaryWindowController: NSWindowController { }

extension PrimaryWindowController: NSWindowDelegate {
	func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		guard let dataController = DataController.shared else { return nil }
		
		if let undoManager = dataController.context.undoManager {
			return undoManager
		} else {
			let undoManager = UndoManager()
			dataController.context.undoManager = undoManager
			return undoManager
		}
	}
}
