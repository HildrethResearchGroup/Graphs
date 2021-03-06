//
//  SidebarViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller that manages the source list showing the hierarchy of directories.
class SidebarViewController: NSViewController {
	/// The source list.
	@IBOutlet weak var sidebar: NSOutlineView!
	/// A button which adds a new non-physical directory.
	@IBOutlet weak var addButton: NSButton!
	/// A button which removes a directory.
	@IBOutlet weak var removeButton: NSButton!
	/// An accessory view to add to NSOpenPanel to allow additional import options.
	@IBOutlet var importAccessoryView: NSView!
	/// A checkbox which determines if subdirectories should be imported during import.
	@IBOutlet weak var importSubdirectoriesCheckbox: NSButton!
	/// Queue used for reading and writing file promises.
	lazy var workQueue: OperationQueue = {
			let providerQueue = OperationQueue()
			providerQueue.qualityOfService = .userInitiated
			return providerQueue
	}()
	/// Directory for accepting promised files.
	lazy var promiseDestinationURL: URL = {
			let promiseDestinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
			try? FileManager.default.createDirectory(at: promiseDestinationURL, withIntermediateDirectories: true, attributes: nil)
			return promiseDestinationURL
	}()
	/// Adds a new directory in the selected directory in the sourcelist. If no directory is selected, the directory is placed at the root directory.
	/// - Parameter sender: The sender.
	@IBAction func addDirectory(_ sender: Any?) {
		guard let dataController = dataController else { return }
		guard let rootDirectory = rootDirectory else { return }
		
		let parent = insertionDirectory() ?? rootDirectory
		
		let newDirectory = dataController.createSubdirectory(in: parent)
		newDirectory.customDisplayName = Directory.defaultDisplayName
		
		// The item is being inserted at the end of the list of children. NSOutlineView.insertItems(at:inParent:withAnimation) takes the parent item to add the new item inside of. In this case, this is the parent directory which was calculated above. It also takes the child index to add the item to - this is simply the index of the (just added) last child subdirectory.
		let endIndex = IndexSet(integer: parent.subdirectories.count - 1)
		// Top level directories are a member of the root directory. However, NSOutlineView represents the item of the top level as nil, so if the parent is the root directory, change it to nil.
		let sidebarParent = parent == rootDirectory ? nil : parent
		
		sidebar.insertItems(at: endIndex,
												inParent: sidebarParent,
												withAnimation: .slideUp)
		// Items are collapsed by default, but should be expanded if an item has just been added to it.
		sidebar.animator().expandItem(parent)
		
		// Get the view for the newly inserted row so we can begin editing its textfield
		let view = sidebar.view(atColumn: 0, row: sidebar.row(forItem: newDirectory), makeIfNecessary: true) as? NSTableCellView
		
		view?.textField?.becomeFirstResponder()
	}
	/// Removes the selected directories in the source-list.
	@IBAction func removeSelectedDirectories(_ sender: Any?) {
		let selection = sidebar.selectedRowIndexes
		guard !selection.isEmpty else { return }
		let selectedDirectories = selection.compactMap { row in
			// This should never return nil (all items in the sourcelist should be directories) however if it does, skip over it, and it will be noted as an error in the following guard statment (we can't break out of a map)
			return sidebar.item(atRow: row) as? Directory
		}
		guard selectedDirectories.count == selection.count else {
			print("NSOutlineView inconsitancty: could not map all rows to directories")
			return
		}
		remove(directories: selectedDirectories)
	}
	
	override func viewDidLoad() {
		registerObservers()
		// Allow dropping internal directory types and external files on the sidebar
		sidebar.registerForDraggedTypes([.directoryRowPasteboardType, .fileRowPasteboardType, .fileURL])
		// Allow dragging rows to the trash to delete them
		sidebar.setDraggingSourceOperationMask([.delete], forLocal: false)
		sidebar.reloadData()
	}
}

// MARK: Helper Functions
extension SidebarViewController {
	/// The data controller that manages the model.
	var dataController: DataController? {
		return .shared
	}
	/// The root directory.
	var rootDirectory: Directory? {
		return dataController?.rootDirectory
	}
	/// The managed object context for the model.
	var dataContext: NSManagedObjectContext? {
		return dataController?.context
	}
	/// Inserts files/directories in the given directory.
	/// - Parameters:
	///   - urls: The urls of the files and directories to add.
	///   - outlineView: The outlineview that is being dragged into.
	///   - dropDirectory: The directory that files are being added to. If `nil`, the root directory is used.
	///   - childIndex: The index of the child inside the directory that files are being added at. If `nil`, the items are added to the end of the directory.
	///   - includeSubdirectories: Whether or not to include subdirectories of the selection.
	func importURLs(_ urls: [URL], dropDirectory: Directory?, childIndex: Int?, includeSubdirectories: Bool) {
		// If no drop directory is specified then add it to the root directory
		guard let dropDirectory = dropDirectory ?? rootDirectory else {
			print("[WARNING] Could not determine drop directory.")
			return
		}
		// If no child index is scpecified then append it
		let childIndex = childIndex ?? dropDirectory.subdirectories.count
		
		guard let dataController = dataController else { return }
		// Update the model
		dataController.importURLs(urls, to: dropDirectory, childIndex: childIndex, includeSubdirectories: includeSubdirectories)
		
		// Animate
		let outlineParent = dropDirectory == rootDirectory ? nil : dropDirectory
		let folderCount = urls.lazy.filter { $0.isFolder } .count
		let insertionIndexSet = IndexSet(integersIn: childIndex..<(childIndex + folderCount))
		sidebar.insertItems(at: insertionIndexSet, inParent: outlineParent, withAnimation: .slideDown)
		
		// If a file/directory is dropped into a selected directory, its file contents will change, and the files to show in the file list may change
		dataController.updateFilesDisplayed(animate: true)
	}
	/// Removes the given directories from the sidbar and updates the model.
	/// - Parameter directories: The directories to remove.
	func remove(directories: [Directory]) {
		// Multiple items may be removed, so put everything in an update block to improve performance
		sidebar.beginUpdates()
		directories.forEach { directory in
			let parent = directory.parent
			let childIndex = sidebar.childIndex(forItem: directory)
			dataController?.remove(directory: directory)
			
			guard parent != nil else {
				print("[WARNING] Error finding parent for directory item to be removed.")
				return
			}
			guard childIndex != -1 else {
				print("[WARNING] Error finding child index for subdirectory to be removed.")
				return
			}
			
			// Top level directories are a member of the root directory. However, NSOutlineView represents the item of the top level as nil, so if the parent is the root directory, change it to nil.
			let sidebarParent = parent == rootDirectory ? nil : parent
			
			sidebar.removeItems(at: IndexSet(integer: childIndex),
													inParent: sidebarParent,
													withAnimation: .slideDown)
		}
		sidebar.endUpdates()
	}
	/// Recursivley expands the items in the directory based on their `collapsed` property.
	/// - Parameters:
	///   - directory: The directory to expand the items of.
	///   - expandSelf: If `true`, the directory should be expanded if needed before checking its contents to be expanded.
	func expandNeededItems(in directory: Directory, expandSelf: Bool = false) {
		if !directory.collapsed {
			if expandSelf {
				sidebar.expandItem(directory)
			}
			directory.subdirectories.forEach { subdirectory in
				expandNeededItems(in: subdirectory, expandSelf: true)
			}
		} else {
			sidebar.collapseItem(directory)
		}
	}
	/// Returns the directory from the `item` parameter that the `NSOutlineView` uses.
	/// - Parameter item: The `item` parameter returned from the `NSOutlineView`.
	/// - Returns: The directory that the item represents.
	func directoryFromItem(_ item: Any?) -> Directory? {
		// The top level item is given as nil by AppKit.
		guard let item = item else { return rootDirectory }
		// Otherwise the parent directory will have set the item to be a Direcotry object.
		return item as? Directory
	}
	/// Updates the directory selection in the directory controller. This is called to indicate that the files to show in the file list may have changed.
	func updateDirectorySelection() {
		let selectedRows = sidebar.selectedRowIndexes
		let selectedDirectories = selectedRows.compactMap { sidebar.item(atRow: $0) as? Directory }
		// Setting this property calls a setter in DirectoryController which updates the filesToShow property
		dataController?.selectedDirectories = selectedDirectories
	}
	/// Selectes the clicked row or selection of rows.
	func selectClickedRow() {
		if sidebar.clickedRow >= 0 {
			sidebar.selectRowIndexes(IndexSet(integer: sidebar.clickedRow),
															 byExtendingSelection: false)
		} else {
			sidebar.selectRowIndexes(IndexSet(),
															 byExtendingSelection: false)
		}
		updateDirectorySelection()
	}
	/// Selectes the clicked row if it is not in the current selection.
	func selectClickedRowIfNotInSelection() {
		if sidebar.clickedRow >= 0 && !sidebar.selectedRowIndexes.contains(sidebar.clickedRow) {
			// Right clicking on an unselected row, so delete that row
			sidebar.selectRowIndexes(IndexSet(integer: sidebar.clickedRow),
															 byExtendingSelection: false)
			updateDirectorySelection()
		}
	}
	/// The folder that new folder's should be inserted into or imported into.
	func insertionDirectory() -> Directory? {
		switch sidebar.selectedRowIndexes.count {
		case 0:
			// If no cell is selected, place the new directory in the root directory.
			return nil
		case 1:
			// If one cell is selected, place the new directory in that cell's directory.
			let selectedItem = sidebar.item(atRow: sidebar.selectedRow)
			return directoryFromItem(selectedItem)
		default:
			// If multiple cells are selected, place the new directory in the last cell's directory.
			let selectedItem = sidebar.item(atRow: sidebar.selectedRowIndexes.last!)
			return directoryFromItem(selectedItem)
		}
	}
}

// MARK: Notifications
extension SidebarViewController {
	/// Register observers for relevent notifications.
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		// The data will have to be reloaded once the store is loaded
		notificationCenter.addObserver(self,
																	 selector: #selector(storeLoaded),
																	 name: .storeLoaded,
																	 object: nil)
		
		// When undo/redo is called the sidebar may need to be reloaded, so track when undo and redo is called. NSUndoManagerDidRedo/Undo is not used because when that notificaiton is fired there is processing that must be done first
		notificationCenter.addObserver(self,
																	 selector: #selector(didUndo(_:)),
																	 name: .didProcessUndo,
																	 object: nil)
		
		// When the name of a directory changes, it needs to be updated in the sidebar
		notificationCenter.addObserver(self,
																	 selector: #selector(directoryRenamed(_:)),
																	 name: .directoryRenamed,
																	 object: nil)
	}
	/// Called when the Core Data store has loaded.
	@objc func storeLoaded() {
		sidebar.reloadData()
		guard let rootDirectory = rootDirectory else { return }
		// NSOutlineView cannot remember the configuration of which items are collapsed without implementing persistance methods in the delegate, so the items must be manually expanded.
		expandNeededItems(in: rootDirectory)
	}
	/// Called when undo or redo is called.
	@objc func didUndo(_ notification: Notification) {
		// We don't know what is being un/redone, so we have to reload the data rather than perform an insert/delete/move
		sidebar.reloadData()
		guard let rootDirectory = rootDirectory else { return }
		// NSOutlineView cannot remember the configuration of which items are collapsed without implementing persistance methods in the delegate, so the items must be manually expanded.
		expandNeededItems(in: rootDirectory)
		// Calling reload data changed the selection
		updateDirectorySelection()
	}
	/// Called when a directory has been renamed.
	@objc func directoryRenamed(_ notification: Notification) {
		guard let directory = notification.object as? Directory else {
			print("[WARNING] directoryRenamed notification did not have an object of type Directory")
			return
		}
		sidebar.reloadItem(directory)
	}
}
