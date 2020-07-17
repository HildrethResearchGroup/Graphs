//
//  DataController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

/// A class that manages the Core Data store for the app. Use this class to interact with the model.
///
/// This is a singleton class, and should be accessed with the `shared` property.
class DataController {
	/// The container that manages Core Data.
	private var persistentContainer: NSPersistentContainer
	/// A subcontroller which manages when the application should save its state.
	private var saveController: SaveController!
	/// A subcontroller which manages the directory hierarchy.
	private var directoryController: DirectoryController!
	/// A subcontroller which manages the files that are displayed.
	private var fileController: FileController!
	/// A subcontroller which manages file parsers.
	private var parserController: ParserController!
	/// A subcontroller which manages graph templates.
	private var graphController: GraphController!
	/// Creates a `DataController` and runs the completion handler after Core Data has loaded the model from the store.
	/// - Parameter completion: The completion handler to run after Core Data has loaded the model.
	init(completion: @escaping () -> ()) {
		persistentContainer = NSPersistentContainer(name: Self.dataModelName)
		// By default there is no undo manager, so set a new one.
		persistentContainer.viewContext.undoManager = UndoManager()
		
		saveController = .init(dataController: self)
		directoryController = .init(dataController: self)
		fileController = .init(dataController: self)
		parserController = .init(dataController: self)
		graphController = .init(dataController: self)
		
		loadStore(completion: completion)
		registerObservers()
	}
}

// MARK: Notifications
extension DataController {
	/// Called when the user has requested an undo operation.
	@objc private func didUndo(_ notification: Notification) {
		// A cache is built up over time to prevent unneded computations. When an undo is called however, we dob not know what is being undone so we can't simply update the cache, we have to entirely invalidate it
		Directory.invalidateCache()
		fileController.invalidateSortCache()
		// Send a notificatoin that the undo has been processed and that view controllers should no update their contents. View controllers listen to this notification instead of NSUndoManagerDidUndo/RedoChange becuase if they listen to that notificaion, the cache may be invalidated after the view controller updates its views.
		let notification = Notification(name: .didProcessUndo)
		NotificationCenter.default.post(notification)
	}
	/// Registers the controller to listen for notifications.
	private func registerObservers() {
		// Must register for undo/redo notifications to invalidate any caches.
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(didUndo(_:)),
																					 name: .NSUndoManagerDidUndoChange,
																					 object: context.undoManager)
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(didUndo(_:)),
																					 name: .NSUndoManagerDidRedoChange,
																					 object: context.undoManager)
	}
}

// MARK: Singleton
extension DataController {
	/// The shared `DataController` instance for the app.
	///
	/// This needs to be set when the application launches by calling `DataController.initialize()`.
	private(set) static var shared: DataController? {
		didSet {
			let notification = Notification(name: .storeLoaded)
			NotificationCenter.default.post(notification)
		}
	}
	/// Initializes the shared controller instance.
	/// - Parameter completion: The code to execute when the data controller has finished initializing.
	static func initialize(completion: @escaping () -> ()) {
		DataController.shared = DataController.init(completion: completion)
	}
}

// MARK: Store Helper Functions
extension DataController {
	/// The name of the Core Data model.
	private static let dataModelName = "GraphsModel"
	/// The store type for Core Data to use (SQLite).
	///
	/// SQLite is used because it is nonatomic, so the whole datagraph doesn't need to be all loaded in memory at all times.
	private static let storeType = "sqlite"
	/// The view context for the persistent container.
	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
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
			print("[INFO] Core Data store exists. Attempting to delete.")
		} else {
			print("[INFO] Core Data store does not exist.")
			return
		}
		
		do {
			let coordinator = persistentContainer.persistentStoreCoordinator
			try coordinator.destroyPersistentStore(at: url,
																						 ofType: Self.dataModelName,
																						 options: nil)
			print("[INFO] Core Data store deleted.")
		} catch {
			print("[WARNING] Core Data store not deleted: \(error)")
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
			// Sometimes the NSOutlineView wrongfully collapses the root -- set it on load to not be collapsed. Without doing this, the top level items may not auto-expand on load.
			self.directoryController.rootDirectory?.collapsed = false
			self.parserController.loadParsers()
			self.graphController.loadGraphTemplates()
			completion()
		}
	}
}

// MARK: Saving Interface
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

// MARK: Directory Interface
extension DataController {
	/// The currently selected directories in the sidebar.
	var selectedDirectories: [Directory] {
		get {
			return directoryController.selectedDirectories
		}
		set {
			directoryController.selectedDirectories = newValue
		}
	}
	/// The root directory. All directories are decendents of this directory.
	var rootDirectory: Directory? {
		return directoryController.rootDirectory
	}
	/// Creates a new subdirectory in the given directory.
	/// - Parameter parent: The directory to create a subdirectory inside of.
	/// - Returns: The new directory that was created.
	@discardableResult
	func createSubdirectory(in parent: Directory) -> Directory {
		return directoryController.createSubdirectory(in: parent)
	}
	/// Removes the given directory and its contents.
	/// - Parameter directory: The directory to remove.
	func remove(directory: Directory) {
		directoryController.remove(directory: directory)
	}
	/// Renames a directory.
	/// - Parameters:
	///   - directory: The directory to rename.
	///   - newName: The new name of the directory.
	func rename(directory: Directory, to newName: String?) {
		directoryController.rename(directory: directory, to: newName)
	}
}

// MARK: File Interface
extension DataController {
	/// The files in the directories that are selected and sorted if a sort key is given.
	var filesDisplayed: [File] {
		return fileController.filesToShow
	}
	/// The currently selected files.
	var filesSelected: [File] {
		get {
			return fileController.filesSelected
		}
		set {
			fileController.filesSelected = newValue
		}
	}
	/// The current sort key for the file list.
	var fileSortKey: File.SortKey? {
		get {
			return fileController.sortKey
		}
		set {
			fileController.sortKey = newValue
		}
	}
	/// The direction of sorting for file list.
	var sortFilesAscending: Bool {
		get {
			return fileController.sortAscending
		}
		set {
			fileController.sortAscending = newValue
		}
	}
	/// Updates the files that should be shown based off the directory selection.
	/// - Parameter animate: If `true` the changes will be animated in the table view.
	func updateFilesDisplayed(animate: Bool) {
		fileController.updateFilesToShow(animate: animate)
	}
	/// Renames the given file.
	/// - Parameters:
	///   - file: The file to rename.
	///   - newName: The new name of the file.
	func rename(file: File, to newName: String?) {
		fileController.rename(file: file, to: newName)
	}
}

// MARK: Parser Interface
extension DataController {
	/// The parsers that have been created.
	var parsers: [Parser] {
		return parserController.parsers
	}
	/// Creates a new parser.
	/// - Returns: A new parser.
	@discardableResult
	func createParser() -> Parser {
		return parserController.createParser()
	}
	/// Removes the given parser.
	/// - Parameter parser: The parser to remove.
	func remove(parser: Parser) {
		parserController.remove(parser: parser)
	}
	/// The parser to use for the given directory item.
	/// - Parameter directoryItem: The directory item to find the parser for.
	/// - Returns: The parser to use for the given file, or the default parser for the given directory.
	///
	/// The parser for a given file is determined as follows: if the file has a custom parser, that parser is used. Otherwise the file has a toggle for which parser to choose from:
	///
	/// 1. *By folder:* the parser of the closet ansestor's default parser is used.
	/// 2. *By file type:* the default parser of the file's file type is used.
	///
	/// If there is no parser for the file's chosen method (by folder/file type) then the other method is used. If niether method has a default, then the file has no default parser.
	func parser(for directoryItem: DirectoryItem) -> Parser? {
		return parserController.parser(for: directoryItem)
	}
	/// Returns the default parsers for the given file type.
	/// - Parameter fileType: The file type (extension) to find the default parser for.
	/// - Returns: The default parser for the given file type, or `nil` if there isn't one.
	func defaultParsers(forFileType fileType: String) -> [Parser] {
		return parserController.defaultParsers(forFileType: fileType)
	}
	/// Renames the given parser.
	/// - Parameters:
	///   - parser: The parser to rename.
	///   - newName: The new name of the parser.
	func rename(parser: Parser, to newName: String) {
		parserController.rename(parser: parser, to: newName)
	}
	/// Changes the default file types for the given parser.
	/// - Parameters:
	///   - parser: The parser to change its default file types.
	///   - fileTypes: The extensions of the file types that should default to this parser.
	func changeDefaultFileTypes(for parser: Parser, to fileTypes: [String]) {
		parserController.changeDefaultFileTypes(for: parser, to: fileTypes)
	}
}

// MARK: Graph Interface
extension DataController {
	var graphTemplates: [GraphTemplate] {
		return graphController.graphTemplates
	}
	/// Loads the imported graph templates from Core Data.
	func loadGraphTemplates() {
		graphController.loadGraphTemplates()
	}
	/// Imports a graph template from a file url.
	/// - Parameter url: The file url of the graph template.
	/// - Returns: The graph template and its associated controller if it could successfully be created, otherwise `nil`.
	func importGraphTemplate(from url: URL) -> (template: GraphTemplate, controller: DGController)? {
		return graphController.importGraphTemplate(from: url)
	}
	/// Deletes the diven graph template.
	/// - Parameter graphTemplate: The graph template to remove.
	func remove(graphTemplate: GraphTemplate) {
		context.delete(graphTemplate)
		return graphController.remove(graphTemplate: graphTemplate)
	}
	/// Renames the graph template.
	/// - Parameters:
	///   - graphTemplate: The graph template to rename.
	///   - newName: The new name of the template.
	func rename(graphTemplate: GraphTemplate, to newName: String) {
		return graphController.rename(graphTemplate: graphTemplate, to: newName)
	}
	/// The graph template to use for the given directory item.
	/// - Parameter directoryItem: The item to find the template for.
	/// - Returns: The graph template that should be used for file types or the default graph template for directory types.
	func graphTemplate(for directoryItem: DirectoryItem) -> GraphTemplate? {
		return graphController.graphTemplate(for: directoryItem)
	}
}
