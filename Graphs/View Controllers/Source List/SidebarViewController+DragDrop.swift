//
//  SidebarViewController+DragDrop.swift
//  Graphs
//
//  Created by Connor Barnes on 4/30/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
	// A UTI string that should be a unique identifier
	static let directoryRowPasteboardType = Self("com.connorbarnes.graphs.directoryRowPasteboardType")
}

extension SidebarViewController {
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		
		//guard let directory = directoryFromItem(item) else { return nil }
		
		let row = outlineView.row(forItem: item)
		let pasteboardItem = NSPasteboardItem()
		let propertyList = [DirectoryPasteboardWriter.UserInfoKeys.row: row]
		pasteboardItem.setPropertyList(propertyList, forType: .directoryRowPasteboardType)
		
		return pasteboardItem
	}
	
	private func okayToDrop(draggingInfo: NSDraggingInfo, destinationItem: Directory?) -> Bool {
		
		guard let destinationItem = destinationItem else { return true }
		let ansestors = destinationItem.ansestors
		var droppedOntoSelf = false
		
		draggingInfo.enumerateDraggingItems(options: [], for: sidebar, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
			guard let droppedPasteboardItem = dragItem.item as? NSPasteboardItem else { return }
			
			guard let dropDirectory = self.directoryFromPasteboardItem(droppedPasteboardItem) else { return }
			
			// Check if the dropped item is the parent of the location item
			if ansestors.contains(dropDirectory) {
				// Dropping a parent directory into this directory, which would create an infinite cycle, so don't allow this
				droppedOntoSelf = true
			}
		}
		
		return !droppedOntoSelf
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info:
		NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		var result = NSDragOperation()
		
		// Don't allow dropping on a child
		guard index != -1 else { return result }
		// Make sure we have a valid item to drop onto
		guard item != nil else { return result }
		
		guard let dropDirectory = directoryFromItem(item) else { return result }
		
		if info.draggingPasteboard.availableType(from: [.directoryRowPasteboardType]) != nil {
			// Drag source is from within the outline view
			if okayToDrop(draggingInfo: info, destinationItem: dropDirectory) {
				result = .move
			}
		} else if info.draggingPasteboard.availableType(from: [.fileURL]) != nil {
			// Drag source is from outside the app as a file URL, so a drop means adding a link or reference
			result = .link
		} else {
			// Drag source is from outside the app, likly a file promise, so it's going to be a copy
			result = .copy
		}
		
		return result
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.outlineView(_:acceptDrop:item:childIndex:")
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.outlineView(_:draggingSession:endedAt:operation:)")
	}
	
	// MARK: Utilities
	
	private func directoryFromPasteboardItem(_ item: NSPasteboardItem) -> Directory? {
		// Get the row number from the property list
		
		guard let plist = item.propertyList(forType: .directoryRowPasteboardType) as? [String: Any] else { return nil }
		guard let row = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else { return nil }
		
		// Ask the sidebar for the directory at that row
		return sidebar.item(atRow: row) as? Directory
	}
}
