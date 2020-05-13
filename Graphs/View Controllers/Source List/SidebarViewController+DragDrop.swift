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
		let row = outlineView.row(forItem: item)
		let pasteboardItem = NSPasteboardItem()
		// The property list simply contains the row of the directory. The directory associated with this row can be easily obtained later
		let propertyList = [DirectoryPasteboardWriter.UserInfoKeys.row: row]
		pasteboardItem.setPropertyList(propertyList, forType: .directoryRowPasteboardType)
		return pasteboardItem
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info:
		NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		var result = NSDragOperation()
		
		// Don't allow dropping on a child
		guard index != -1 else { return result }
		
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
		
		if info.draggingPasteboard.availableType(from: [.directoryRowPasteboardType]) != nil {
			// The items that are being dragged are internal items
			if let dropDirectory = directoryFromItem(item) ?? rootDirectory {
				handleInternalDrops(outlineView, draggingInfo: info, dropDirectory: dropDirectory, childIndex: index)
				return true
			}
			
		}
		
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.outlineView(_:acceptDrop:item:childIndex:")
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		if operation == .delete {
			// This is called when dragging to the trash can
			let items = session.draggingPasteboard.pasteboardItems
			let itemsToRemove = items?.compactMap { (draggedItem) -> Directory? in
				return directoryFromItem(draggedItem)
			}
			#warning("Not implemented")
			fatalError("Not implemented")
		}
		
		
		
		#warning("Not implemented")
		print("[WARNING] Called unimplemented method: SidebarViewController.outlineView(_:draggingSession:endedAt:operation:)")
	}
}

// MARK: Utilities
extension SidebarViewController {
	/// Returns true if the items being dragged can be dropped at the given location. This checks to make sure that a directory is not placed inside one of its children.
	/// - Parameters:
	///   - draggingInfo: The dragging info passed to the delegate method.
	///   - destinationItem: The directory that is being dropped onto.
	/// - Returns: True if the drop is okay, and false otherwise.
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
	
	/// Handles dropping internal items onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outlineview being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleInternalDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, dropDirectory: Directory, childIndex index: Int) {
		var itemsToMove: [Directory] = []
		
		// If the drop location is ambiguous, add it to the end
		let dropIndex = index == -1 ? dropDirectory.children.count : index
		
		draggingInfo.enumerateDraggingItems(options: [], for: outlineView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
			if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
				if let itemToMove = self.directoryFromPasteboardItem(droppedPasteboardItem) {
					itemsToMove.append(itemToMove)
				}
			}
		}
		
		// The items may be added at a higher index if there are selected items in the drop directory that are above the drop zone
		let indexOffset = itemsToMove.lazy.filter { directory -> Bool in
			// The parent of the item being moved has to be the same as the drop directory
			if directory.parent != dropDirectory { return false }
			let directoryIndex = dropDirectory.children.index(of: directory)
			guard directoryIndex != -1 else {
				// The index of the item should never be -1 because it's parent is the drop directory (thus it should be in the children set)
				print("[WARNING] Internal error: index of directory child was nil")
				return false
			}
			
			// The item being moved has to be above the drop location
			return directoryIndex < dropIndex
		}.count
		
		let insertIndex = dropIndex - indexOffset
		
		// Each item will have a move animation, so put in an updates block
		outlineView.beginUpdates()
		// Becuase each item is added individually as a child, it needs to be done in reverse order, otherwise the items would be pasted in the wrong order
		itemsToMove.reversed().forEach { directory in
			let origionalParent = directory.parent == rootDirectory ? nil : directory.parent
			let origionalIndex = outlineView.childIndex(forItem: directory)
			// Remove the directories to be moved from their parent
			directory.parent?.removeFromChildren(directory)
			directory.parent = nil
			// Then make these directories' new parent the drop parent
			dropDirectory.insertIntoChildren(directory, at: insertIndex)
			
			let newParent = dropDirectory == rootDirectory ? nil : dropDirectory
			
			// Then add animation
			outlineView.moveItem(at: origionalIndex, inParent: origionalParent, to: insertIndex, inParent: newParent)
			
			// If there are no more subdirectories for the parent of the direcotry that has just had its children moved, the disclosure triangle for that row should be hidden. To do that, the parent item is reloaded if it has no more subdirectories
			if (origionalParent?.subdirectories.count == 0) {
				outlineView.reloadItem(origionalParent, reloadChildren: false)
			}
		}
		outlineView.endUpdates()
	}
	
	/// Extracts the directory from an NSPasteboardItem instance.
	/// - Parameter item: The pasteboard item.
	/// - Returns: The directory associated with the pasteboard item if there is one.
	private func directoryFromPasteboardItem(_ item: NSPasteboardItem) -> Directory? {
		// Get the row number from the property list
		
		guard let plist = item.propertyList(forType: .directoryRowPasteboardType) as? [String: Any] else { return nil }
		guard let row = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else { return nil }
		
		// Ask the sidebar for the directory at that row
		return sidebar.item(atRow: row) as? Directory
	}
}
