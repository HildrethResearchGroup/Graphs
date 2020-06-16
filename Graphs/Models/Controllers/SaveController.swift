//
//  SaveController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

/// A class that keeps tracks of changes in Core Data and uses this to determine when to save.
class SaveController {
	/// The data controller which controlls the Core Data store.
	private unowned let dataController: DataController
	/// How long to wait between subsequent save operations.
	private static let saveInterval: TimeInterval = 60.0
	/// The maximum number of changes to allow before saving.
	private static let changeThreshhold = 50
	/// The Core Data context to manage saving of.
	private weak var context: NSManagedObjectContext?
	/// The number of changes since the last save.
	private var changeCount = 0 {
		didSet {
			// After a certain number of changes have been made save. This is to prevent the user from loosing changes if an unexpected crash occurs.
			if changeCount == Self.changeThreshhold {
				save()
			}
		}
	}
	/// A timer that calls `save()` when it fires.
	private var saveTimer = Timer()
	/// Creates a save controller from a data controller.
	/// - Parameter dataController: The data controller to use.
	init(dataController: DataController) {
		self.dataController = dataController
	}
}

// MARK: Interface
extension SaveController {
	/// Registers a new change. Call this when a change has been made which will eventually require saving.
	func addChange() {
		changeCount += 1
	}
	/// Saves the Core Data model to the store if there have been any changes since the last save.
	func save() {
		// Don't save if there hasn't been any changes
		guard changeCount > 0 else { return }
		
		do {
			try dataController.context.save()
		} catch {
			print("[WARNING] Core Data failed to save: \(error)")
		}
		// Change count represents the number of changes since the last save. Since we just saved set it to 0
		changeCount = 0
	}
}
