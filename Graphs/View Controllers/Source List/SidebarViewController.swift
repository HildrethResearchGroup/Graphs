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
	
	/// Queue used for reading and writing file promises.
	lazy var workQueue: OperationQueue = {
			let providerQueue = OperationQueue()
			providerQueue.qualityOfService = .userInitiated
			return providerQueue
	}()
	
	override func viewDidLoad() {
		// The data will have to be reloaded once the store is loaded.
		NotificationCenter.default.addObserver(self, selector: #selector(storeLoaded), name: .storeLoaded, object: nil)
		
		// Register drag types
		sidebar.registerForDraggedTypes([.directoryRowPasteboardType, .fileURL])
		
		sidebar.reloadData()
	}
	
	/// Called when the Core Data store has loaded.
	@objc func storeLoaded() {
		sidebar.reloadData()
		guard let rootDirectory = rootDirectory else { return }
		// NSOutlineView cannot remember the configuration of which items are collapsed without implementing persistance methods in the delegate, so the items must be manually expanded.
		expandNeededItems(in: rootDirectory)
	}
	
	/// Adds a new non-physical directory in the selected directory in the sourcelist. If no directory is selected, the directory is placed at the root directory.
	/// - Parameter sender: The sender.
	@IBAction func addDirectory(_ sender: Any?) {
		guard let directoryController = directoryController else { return }
		guard let rootDirectory = rootDirectory else { return }
		
		let selection = sidebar.selectedRowIndexes
		let parent: Directory
		
		switch selection.count {
		case 0:
			// If no cell is selected, place the new directory in the root directory.
			parent = rootDirectory
		case 1:
			// If one cell is selected, place the new directory in that cell's directory.
			let selectedItem = sidebar.item(atRow: sidebar.selectedRow)
			parent = directoryFromItem(selectedItem) ?? rootDirectory
		default:
			// If multiple cells are selected, place the new directory in the last cell's directory.
			let selectedItem = sidebar.item(atRow: selection.last!)
			parent = directoryFromItem(selectedItem) ?? rootDirectory
		}
		
		let newDirectory = directoryController.createSubdirectory(in: parent)
		// The directory is non-physical, so it needs a display name.
		newDirectory.customDisplayName = "New Directory"
		
		// The item is being inserted at the end of the list of children. NSOutlineView.insertItems(at:inParent:withAnimation) takes the parent item to add the new item inside of. In this case, this is the parent directory which was calculated above. It also takes the child index to add the item to - this is simply the index of the (just added) last child subdirectory.
		let endIndex = IndexSet(integer: parent.subdirectories.count - 1)
		// Top level directories are a member of the root directory. However, NSOutlineView represents the item of the top level as nil, so if the parent is the root directory, change it to nil.
		let sidebarParent = parent == rootDirectory ? nil : parent
		
		sidebar.insertItems(at: endIndex,
												inParent: sidebarParent,
												withAnimation: .slideUp)
		// Items are collapsed by default, but should be expanded if an item has just been added to it.
		sidebar.animator().expandItem(parent)
	}
	
	/// Removes the selected directory in the source-list.
	@IBAction func removeDirectory(_ sender: Any?) {
		let selection = sidebar.selectedRowIndexes
		
		guard !selection.isEmpty else { return }
		
		let selectedDirectories = selection.compactMap { row in
			return sidebar.item(atRow: row) as? Directory
		}
		
		guard selectedDirectories.count == selection.count else {
			print("NSOutlineView inconsitancty: could not map all rows to directories")
			return
		}
		
		sidebar.beginUpdates()
		selectedDirectories.forEach { directory in
			let parent = directory.parent
			let childIndex = sidebar.childIndex(forItem: directory)
			directoryController?.remove(directory: directory)
			
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
			
			// If there are no more subdirectories for the parent of the direcotry that has just been deleted, the disclosure triangle for that row should be hidden. To do that, the parent item is reloaded if it has no more subdirectories
			if (parent?.subdirectories.count == 0) {
				sidebar.reloadItem(sidebarParent, reloadChildren: false)
			}
		}
		sidebar.endUpdates()
	}
	
}

// MARK: Helper Functions
extension SidebarViewController {
	/// The data controller that manages the model.
	var dataController: DataController? {
		return .shared
	}
	
	/// The directory controller.
	var directoryController: DirectoryController? {
		return dataController?.directoryController
	}
	
	/// The root directory.
	var rootDirectory: Directory? {
		return directoryController?.rootDirectory
	}
	
	/// The managed object context for the model.
	var dataContext: NSManagedObjectContext? {
		return dataController?.persistentContainer.viewContext
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
}
