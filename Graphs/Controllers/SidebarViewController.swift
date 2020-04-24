//
//  SidebarViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
	/// The source list.
	@IBOutlet weak var sidebar: NSOutlineView!
	/// A button which adds a new non-physical directory.
	@IBOutlet weak var addButton: NSButton!
	
	override func viewDidLoad() {
		// The data will have to be reloaded once the store is loaded.
		NotificationCenter.default.addObserver(self, selector: #selector(storeLoaded), name: .storeLoaded, object: nil)
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
	@IBAction func addDirectory(_ sender: Any) {
		guard let context = dataContext else { return }
		guard let rootDirectory = rootDirectory else { return }
		
		let newDirectory = Directory(context: context)
		// The directory is non-physical, so it needs a display name.
		newDirectory.customDisplayName = "New Directory"
		
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
			// TODO: Determine what to do when multiple elements are selected and a new directory is created.
			print("Selection of multiple elements")
			return
		}
		
		parent.addToChildren(newDirectory)
		dataController?.setNeedsSaved()
		// TODO: All of the data doesn't need to be reloaded. Instead an insertion should be performed. This also has the benefit of having an animation.
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

// MARK: NSOutlineViewDataSource
extension SidebarViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let directory = directoryFromItem(item) else { return 0 }
		return directory.subdirectories.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		// TODO: Add better error handling than crashing.
		guard let directory = directoryFromItem(item) else { fatalError() }
		return directory.subdirectories[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let directory = directoryFromItem(item) else { return false }
		return !directory.subdirectories.isEmpty
	}
}

// MARK: NSOutlineViewDelegate
extension SidebarViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let directory = directoryFromItem(item) else { return nil }
		let identifier = NSUserInterfaceItemIdentifier(rawValue: "DirectoryCell")
		let view = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
		view?.textField?.stringValue = directory.displayName
		return view
	}
	
	func outlineViewItemDidExpand(_ notification: Notification) {
		guard let item = notification.userInfo?["NSObject"] as? Directory else {
			return
		}
		item.collapsed = false
		expandNeededItems(in: item)
		dataController?.setNeedsSaved()
	}
	
	func outlineViewItemDidCollapse(_ notification: Notification) {
		guard let item = notification.userInfo?["NSObject"] as? Directory else {
			return
		}
		item.collapsed = true
		dataController?.setNeedsSaved()
	}
}
