//
//  FileListViewController+DragDrop.swift
//  Graphs
//
//  Created by Connor Barnes on 6/7/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
	// A UTI string that should be a unique identifier
	static let fileRowPasteboardType = Self("com.connorbarnes.graphs.fileRowPasteboardType")
}

extension FileListViewController {
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		let pasteboardItem = NSPasteboardItem()
		// The property list simply contains the row of the file. The file associated with this row can be easily obtained later
		let propertyList = [DirectoryPasteboardWriter.UserInfoKeys.row: row]
		pasteboardItem.setPropertyList(propertyList, forType: .fileRowPasteboardType)
		return pasteboardItem
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		if operation == .delete {
			// This is called when dragging to the trash can
			guard let items = session.draggingPasteboard.pasteboardItems else { return }
			let filesToRemove = items.compactMap { (draggedItem) -> File? in
				guard let plist = draggedItem.propertyList(forType: .fileRowPasteboardType) as? [String: Any] else { return nil }
				guard let rowIndex = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else {
					return nil
				}
				
				return directoryController?.filesToShow[rowIndex]
			}
			remove(files: filesToRemove)
		}
	}
}
