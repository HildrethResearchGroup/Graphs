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
			if okayToDropDirectories(draggingInfo: info, destinationItem: dropDirectory) {
				result = .move
			}
		} else if info.draggingPasteboard.availableType(from: [.fileRowPasteboardType]) != nil {
			// Drag source is from the file tableview
			// Files cannot be placed in the root directory
			if dropDirectory != rootDirectory {
				result = .move
			}
		} else if info.draggingPasteboard.availableType(from: [.fileURL]) != nil {
			// Drag source is from outside the app as a file URL, so a drop means adding a link or reference
			if !(item == nil && externalDropContainsFiles(draggingInfo: info)) {
				return .link
			}
		} else {
			// Drag source is from outside the app, likly a file promise, so it's going to be a copy
			result = .copy
		}
		return result
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		guard let dropDirectory = directoryFromItem(item) ?? rootDirectory else { return false }
		
		if info.draggingPasteboard.availableType(from: [.directoryRowPasteboardType]) != nil {
			// The items that are being dragged are internal items
			handleInternalDirectoryDrops(outlineView, draggingInfo: info, dropDirectory: dropDirectory, childIndex: index)
		} else if info.draggingPasteboard.availableType(from: [.fileRowPasteboardType]) != nil {
			handleInternalFileDrops(outlineView, draggingInfo: info, dropDirectory: dropDirectory, childIndex: index)
		} else {
			// The user has droped items from Finder
			handleExternalDrops(outlineView, draggingInfo: info, dropDirectory: dropDirectory, childIndex: index)
		}
		return true
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		if operation == .delete {
			// This is called when dragging to the trash can
			guard let items = session.draggingPasteboard.pasteboardItems else { return }
			let directoriesToRemove = items.compactMap { (draggedItem) -> Directory? in
				guard let plist = draggedItem.propertyList(forType: .directoryRowPasteboardType) as? [String: Any] else { return nil }
				guard let rowIndex = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else {
					return nil
				}
				
				let item = outlineView.item(atRow: rowIndex)
				return directoryFromItem(item)
			}
			remove(directories: directoriesToRemove)
		}
	}
}

// MARK: Utilities
extension SidebarViewController {
	/// Returns true if the directories being dragged can be dropped at the given location. This checks to make sure that a directory is not placed inside one of its children.
	/// - Parameters:
	///   - draggingInfo: The dragging info passed to the delegate method.
	///   - destinationItem: The directory that is being dropped onto.
	/// - Returns: True if the drop is okay, and false otherwise.
	private func okayToDropDirectories(draggingInfo: NSDraggingInfo, destinationItem: Directory?) -> Bool {
		
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
	
	private func externalDropContainsFiles(draggingInfo: NSDraggingInfo) -> Bool {
		// We look for file promises and urls
		let supportedClasses = [NSFilePromiseReceiver.self, NSURL.self]
		// For items dragged from outside the application, we want to seach for readable URLs
		let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
		var droppedURLs: [URL] = []
		// Process all pasteboard items that are being dropped
		draggingInfo.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { draggingItem, _, _ in
			switch draggingItem.item {
			case let filePromiseReceiver as NSFilePromiseReceiver:
				// The drag item is a file promise, so it isn't a directory
				break
			case let fileURL as URL:
				// The drag item is a URL reference (not a file promise)
				droppedURLs.append(fileURL)
			default:
				break
			}
		}
		
		return droppedURLs.contains { url in
			return !url.isFolder
		}
	}
	
	/// Handles dropping internal items onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outlineview being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleInternalDirectoryDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, dropDirectory: Directory, childIndex index: Int) {
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
		// Each item will have a move animation, so put in an update block to improve performance
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
	
	private func handleInternalFileDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, dropDirectory: Directory, childIndex index: Int) {
		var itemsToMove: [File] = []
		
		draggingInfo.enumerateDraggingItems(options: [], for: outlineView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
			if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
				if let itemToMove = self.fileFromPasteboardItem(droppedPasteboardItem) {
					itemsToMove.append(itemToMove)
				}
			}
		}
		
		// Move each file
		itemsToMove.forEach { file in
			file.parent?.removeFromChildren(file)
			dropDirectory.addToChildren(file)
			file.parent = dropDirectory
		}
		
		// The moved files will require the file list to refresh its contents
		directoryController?.updateFilesToShow(animate: true)
	}
	
	/// Handles dropping external items onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outlineview being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleExternalDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, dropDirectory: Directory, childIndex index: Int) {
		// We look for file promises and urls
		let supportedClasses = [NSFilePromiseReceiver.self, NSURL.self]
		// For items dragged from outside the application, we want to seach for readable URLs
		let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
		var droppedURLs: [URL] = []
		// Process all pasteboard items that are being dropped
		draggingInfo.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { draggingItem, _, _ in
			switch draggingItem.item {
			case let filePromiseReceiver as NSFilePromiseReceiver:
				// The drag item is a file promise
				// This effectively calls in the promises, so write to - self.destinatioURL
				filePromiseReceiver.receivePromisedFiles(atDestination: self.promiseDestinationURL, options: [:], operationQueue: self.workQueue) { fileURL, error in
					if let error = error {
						// Handle error
						#warning("Not implemented")
						print("[WARNING] Called unimplemented method: SidebarViewController.handleExternalDrops(_:draggingInfo:dropDirectory:childIndex)")
					} else {
						OperationQueue.main.addOperation {
							// Add new directory or insert new file
							#warning("Not implemented")
							print("[WARNING] Called unimplemented method: SidebarViewController.handleExternalDrops(_:draggingInfo:dropDirectory:childIndex)")
						}
					}
				}
			case let fileURL as URL:
				// The drag item is a URL reference (not a file promise)
				droppedURLs.append(fileURL)
			default:
				break
			}
		}
		importURLs(droppedURLs,
							 dropDirectory: dropDirectory,
							 childIndex: index,
							 includeSubdirectories: true)
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
	
	private func fileFromPasteboardItem(_ item: NSPasteboardItem) -> File? {
		// Get the row number from the property list
		guard let plist = item.propertyList(forType: .fileRowPasteboardType) as? [String: Any] else { return nil }
		guard let row = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else { return nil }
		// We don't have access to the tableview showing the files, but we do have access to the source for the tableview
		return directoryController?.filesToShow[row]
	}
}

extension URL {
	/// Returns true if the url is a file system container. (Packages are not considered containers)
	var isFolder: Bool {
		guard let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) else { return false }
		
		return (resources.isDirectory ?? false) && !(resources.isPackage ?? false)
	}
}
