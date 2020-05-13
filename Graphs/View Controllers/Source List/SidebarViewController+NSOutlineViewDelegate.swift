//
//  SidebarViewController+Datasource.swift
//  Graphs
//
//  Created by Connor Barnes on 5/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: NSOutlineViewDataSource
extension SidebarViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let directory = directoryFromItem(item) else { return 0 }
		return directory.subdirectories.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		// TODO: Add better error handling than crashing.
		guard let directory = directoryFromItem(item) else {
			fatalError("Child of directory at the given index was nil.")
		}
		return directory.subdirectories[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		// Every item is a directory, which can have subdirectories
		return true
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
	
	func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
		// This method is not being called when reload item is called, which is causing the disclosure view to be inconsitantly shown/hidden. For a temporary solution, the disclosure view will be always shown
		// This appears to be a bug with AppKit. I have submitted a bug report, but in the time being, it doesn't look like there is an easy solution to this. One solution was to reload all of the children of the parent item, but this interfered with the animations
		return true
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
