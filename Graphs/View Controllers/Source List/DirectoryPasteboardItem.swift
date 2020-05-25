//
//  DirectoryPasteboardItem.swift
//  Graphs
//
//  Created by Connor Barnes on 4/30/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class DirectoryPasteboardWriter: NSFilePromiseProvider {
	/// An enum holding a list of all the used keys in userDictionary.
	enum UserInfoKeys {
		/// The row of the dragged directory in the sidebar
		static let row = "rowKey"
		/// The name of the directory
		static let name = "nameKey"
		// The url of the directory
		static let url = "urlKey"
	}
	
	// MARK: NSPasteboardWriting
	
	override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
		var types = super.writableTypes(for: pasteboard)
		// As well as promise files, add internal directory pasteboard type and fileURLs.
		types.append(.directoryRowPasteboardType)
		types.append(.fileURL)
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

// MARK: Utilities

extension DirectoryPasteboardWriter {
	class func urlFromFilePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider) -> URL? {
		guard let userInfo = filePromiseProvider.userInfo as? [String: Any] else { return nil }
		
		if let urlString = userInfo[DirectoryPasteboardWriter.UserInfoKeys.url] as? String {
			if !urlString.isEmpty {
				return URL(string: urlString)
			}
		}
		
		return nil
	}
}
