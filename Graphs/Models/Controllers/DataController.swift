//
//  DataController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A class that manages the Core Data store for the app. Use this class to interact with the model.
///
/// This is a singleton class, and should be accessed with the `shared` property.
class DataController: NSObject {
	/// The container that manages Core Data.
	var persistentContainer: NSPersistentContainer
	/// A controller which manages when the application should save its state.
	private var saveController = SaveController()
	/// A controller which manages the directory hierarchy.
	var directoryController: DirectoryController!
	/// Creates a `DataController` and runs the completion handler after Core Data has loaded the model from the store.
	/// - Parameter completion: The completion handler to run after Core Data has loaded the model.
	init(completion: @escaping () -> ()) {
		persistentContainer = NSPersistentContainer(name: Self.dataModelName)
		// By default there is no undo manager, so set a new one.
		persistentContainer.viewContext.undoManager = UndoManager()
		super.init()
		directoryController = .init(dataController: self)
		loadStore(completion: completion)
	}
}

// MARK: Saving

/// A class that keeps tracks of changes in Core Data and uses this to determine when to save.
private class SaveController {
	/// How long to wait between subsequent save operations.
	static let saveInterval: TimeInterval = 60.0
	/// The maximum number of changes to allow before saving.
	static let changeThreshhold = 50
	/// The Core Data context to manage saving of.
	weak var context: NSManagedObjectContext?
	
	/// Registers a new change. Call this when a change has been made which will eventually require saving.
	func addChange() {
		changeCount += 1
	}
	
	/// The number of changes since the last save.
	private var changeCount = 0 {
		didSet {
			if changeCount == Self.changeThreshhold {
				save()
			}
		}
	}
	
	/// A timer that calls `save()` when it fires.
	private var saveTimer = Timer()
	
	/// Saves the Core Data model to the store if there have been any changes since the last save.
	fileprivate func save() {
		// Don't save if there hasn't been any changes
		guard changeCount > 0 else { return }
		guard let context = context else { return }
		
		do {
			try context.save()
		} catch {
			print("[WARNING] Core Data failed to save: \(error)")
		}
		
		// Change count represents the number of changes since the last save. Since we just saved set it to 0
		changeCount = 0
	}
}

extension DataController {
	/// Notifies the controller that the Core Data model has changed and should be saved at some point in the future.
	///
	/// Call this whenever the model changes.
	func setNeedsSaved() {
		saveController.addChange()
	}
	
	/// Immediatley saves the Core Data model to the store.
	///
	/// Note that the store may be saved periodically without this function being called.
	func saveImmediatley() {
		saveController.save()
	}
}

// MARK: Singleton
extension DataController {
	/// The shared `DataController` instance for the app.
	///
	/// This needs to be set when the application launches.
	static var shared: DataController? {
		didSet {
			let notification = Notification(name: .storeLoaded)
			NotificationCenter.default.post(notification)
		}
	}
}

// MARK: Helper Functions
extension DataController {
	/// The name of the Core Data model.
	private static let dataModelName = "GraphsModel"
	/// The store type for Core Data to use (SQLite).
	///
	/// SQLite is used because it is nonatomic, so the whole datagraph doesn't need to be all loaded in memory at all times.
	private static let storeType = "sqlite"
	
	/// Deletes the store.
	///
	/// A useful utility for deleting all data for debugging purposes. When the data schema is changed, this should be called, or Core Data will fail to read the data. To have this called while in `DEBUG`, simply set `shouldResetCoreData` to `true` in `Debug.swift`.
	///
	/// - Warning: This will perminently delete all saved data.
	private func deleteStore() {
		// The file is stored at ~/ApplicationSupport/Graphs/GraphsModel.sqlite
		let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("Graphs/\(Self.dataModelName).\(Self.storeType)")
		
		if FileManager.default.fileExists(atPath: url.path) {
			print("Core Data store exists. Attempting to delete.")
		} else {
			print("Core Data store does not exist.")
			return
		}
		
		do {
			let coordinator = persistentContainer.persistentStoreCoordinator
			try coordinator.destroyPersistentStore(at: url,
																						 ofType: Self.dataModelName,
																						 options: nil)
			print("Core Data store deleted.")
		} catch {
			print("Core Data store not deleted: \(error)")
		}
	}
	
	/// Loads the saved Core Data model from disk if it exists. Otherwise creates an empty model.
	/// - Parameter completion: The completion handler to run after the data is loaded.
	private func loadStore(completion: @escaping () -> ()) {
		#if DEBUG
		if shouldResetCoreData {
			deleteStore()
		}
		#endif
		
		persistentContainer.loadPersistentStores { (description, error) in
			// TODO: Add error handling
			guard error == nil else {
				fatalError("Failed to load Core Data stack: \(error!)")
			}
			
			self.directoryController.loadRootDirectory()
			// Sometimes the NSOutlineView wrongfully collapses the root -- set it on load to no tbe collapsed. Without doing this, the top level items may not auto-expand on load.
			self.directoryController.rootDirectory?.collapsed = false
			
			self.saveController.context = self.persistentContainer.viewContext
			completion()
		}
	}
}
