//
//  Identifiers.swift
//  Graphs
//
//  Created by Connor Barnes on 4/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: Notifications
extension Notification.Name {
	/// A notification that is fired when Core Data's store has loaded the application's data.
	static let storeLoaded = Notification.Name(rawValue: "storeLoaded")
	/// A notification that is fired when the files to show has changed.
	static let filesToShowChanged = Notification.Name(rawValue: "filesToShowChanged")
	/// A notification that is fired after processing an undo by Core Data
	static let didProcessUndo = Notification.Name(rawValue: "didProcessUndo")
}

// MARK: UserInfo keys
enum UserInfoKeys {
	static let oldValue = "oldValue"
}

// MARK: User Interface
extension NSUserInterfaceItemIdentifier {
	static let fileNameColumn: Self = .init("FileNameColumn")
	static let fileCollectionNameColumn: Self = .init("FileCollectionNameColumn")
	static let fileDateImportedColumn: Self = .init("FileDateImportedColumn")
	
	static let fileNameCell: Self = .init("FileNameCell")
	static let fileCollectionNameCell: Self = .init("FileCollectionNameCell")
	static let fileDateImportedCell: Self = .init("FileDateImportedCell")
	
	static let directoryCell: Self = .init("DirectoryCell")
}
