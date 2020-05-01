//
//  DirectoryPasteboardItem.swift
//  Graphs
//
//  Created by Connor Barnes on 4/30/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class DirectoryPasteboardWriter: NSFilePromiseProvider {
	enum UserInfoKeys {
		static let row = "rowKey"
	}
	
	// MARK: NSPasteboardWriting
	
	override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
		var types = super.writableTypes(for: pasteboard)
		types.append(.directoryRowPasteboardType)
		
		return types
	}
	
	override func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
		switch type {
		case .directoryRowPasteboardType:
			// The pasteboard type is the internal directory drag, use userInfo as the property list
			return userInfo
		default:
			// The pasteboard type could be a file promise, the super class can determine the property list.
			return super.pasteboardPropertyList(forType: type)
		}
	}
	
}
