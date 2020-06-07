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
}
