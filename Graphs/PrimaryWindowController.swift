//
//  PrimaryWindowController.swift
//  Graphs
//
//  Created by Connor Barnes on 5/31/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class PrimaryWindowController: NSWindowController {
	
}

extension PrimaryWindowController: NSWindowDelegate {
	func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		guard let dataController = DataController.shared else { return nil }
		
		if let undoManager = dataController.persistentContainer.viewContext.undoManager {
			return undoManager
		} else {
			let undoManager = UndoManager()
			dataController.persistentContainer.viewContext.undoManager = undoManager
			return undoManager
		}
	}
}
