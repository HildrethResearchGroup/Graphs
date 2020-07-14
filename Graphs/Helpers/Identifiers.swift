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
	static let filesDisplayedDidChange = Notification.Name(rawValue: "filesDisplayedDidChange")
	/// A notification that is fired when the selected files has changed.
	static let filesSelectedDidChange = Notification.Name(rawValue: "filesSelectedDidChange")
	/// A notification that is fired when the selected directories have changed.
	static let directoriesSelectedDidChange = Notification.Name(rawValue: "directoriesSelectedDidChange")
	/// A notification that is fired after processing an undo by Core Data
	static let didProcessUndo = Notification.Name(rawValue: "didProcessUndo")
	/// A notification that is fired when the file list is being updated on another thread.
	static let fileListStartedWork = Notification.Name(rawValue: "fileListStartedWork")
	/// A notification that is fired when the  file list has finished updating on another thread.
	static let fileListFinishedWork = Notification.Name(rawValue: "fileListFinishedWord")
	/// A notification that is fired when a directory is renamed.
	static let directoryRenamed = Notification.Name(rawValue: "directoryRenamed")
	/// A notification that is fired when a file is renamed.
	static let fileRenamed = Notification.Name(rawValue: "fileRenamed")
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
	static let fileDateCreatedColumn: Self = .init("FileDateCreatedColumn")
	static let fileDateModifiedColumn: Self = .init("FileDateModifiedColumn")
	static let fileSizeColumn: Self = .init("FileSizeColumn")
	
	static let fileNameCell: Self = .init("FileNameCell")
	static let fileCollectionNameCell: Self = .init("FileCollectionNameCell")
	static let fileDateImportedCell: Self = .init("FileDateImportedCell")
	static let fileDateCreatedCell: Self = .init("FileDateCreatedCell")
	static let fileDateModifiedCell: Self = .init("FileDateModifiedCell")
	static let fileSizeCell: Self = .init("FileSizeCell")
	
	static let directoryCell: Self = .init("DirectoryCell")
	
	static let fileInspectorTab: Self = .init("FileInspectorTab")
	static let directoryInspectorTab: Self = .init("DirectoryInspectorTab")
	static let parserInspectorTab: Self = .init("ParserInspectorTab")
	static let graphInspectorTab: Self = .init("GraphInspectorTab")
	static let dataInspectorTab: Self = .init("DataInspectorTab")
	
	static let fileInspectorSeparatorCell: Self = .init("FileInspectorSeparatorCell")
	static let fileInspectorCategoryCell: Self = .init("FileInspectorCategoryCell")
	static let fileInspectorCategoryOptionCell: Self = .init("FileInspectorCategoryOptionCell")
	static let fileInspectorNameAndLocationCell: Self = .init("FileInspectorNameAndLocationCell")
	static let fileInspectorTemplatesCell: Self = .init("FileInspectorTemplatesCell")
	static let fileInspectorDetailsCell: Self = .init("FileInspectorDetailsCell")
	
	static let directoryInspectorSeparatorCell: Self = .init("DirectoryInspectorSeparatorCell")
	static let directoryInspectorCategoryCell: Self = .init("DirectoryInspectorCategoryCell")
	static let directoryInspectorNameAndLocationCell: Self = .init("DirectoryInspectorNameAndLocationCell")
	static let directoryInspectorTemplatesCell: Self = .init("DirectoryInspectorTemplatesCell")
}
