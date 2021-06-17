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
	/// A notification that is fired when a parser or graph template is changed.
	static let graphMayHaveChanged = Notification.Name(rawValue: "graphMayHaveChanged")
	/// A notification that is fired when a new parser was imported.
	static let didImportParser = Notification.Name(rawValue: "didImportParser")
	static let didImportGraphTemplate = Notification.Name(rawValue: "didImportGraphTempalte")
    static let parserDidStarted = Notification.Name(rawValue: "parserDidStarted")
    static let parserDidEnded = Notification.Name(rawValue: "parserDidEnded")
}

// MARK: UserInfo keys
enum UserInfoKeys {
	static let oldValue = "oldValue"
}

// MARK: File Table Columns
extension NSUserInterfaceItemIdentifier {
    static let fileProgressColumn: Self = .init("FileProgressColumn")
	static let fileNameColumn: Self = .init("FileNameColumn")
	static let fileCollectionNameColumn: Self = .init("FileCollectionNameColumn")
	static let fileDateImportedColumn: Self = .init("FileDateImportedColumn")
	static let fileDateCreatedColumn: Self = .init("FileDateCreatedColumn")
	static let fileDateModifiedColumn: Self = .init("FileDateModifiedColumn")
	static let fileSizeColumn: Self = .init("FileSizeColumn")
}

// MARK: File Table Cells
extension NSUserInterfaceItemIdentifier {
    static let fileProgressCell: Self = .init("FileProgressCell")
	static let fileNameCell: Self = .init("FileNameCell")
	static let fileCollectionNameCell: Self = .init("FileCollectionNameCell")
	static let fileDateImportedCell: Self = .init("FileDateImportedCell")
	static let fileDateCreatedCell: Self = .init("FileDateCreatedCell")
	static let fileDateModifiedCell: Self = .init("FileDateModifiedCell")
	static let fileSizeCell: Self = .init("FileSizeCell")
}

// MARK: Directory Table Cells
extension NSUserInterfaceItemIdentifier {
	static let directoryCell: Self = .init("DirectoryCell")
}

// MARK: Inspector Tabs
extension NSUserInterfaceItemIdentifier {
	static let fileInspectorTab: Self = .init("FileInspectorTab")
	static let directoryInspectorTab: Self = .init("DirectoryInspectorTab")
	static let parserInspectorTab: Self = .init("ParserInspectorTab")
	static let graphInspectorTab: Self = .init("GraphInspectorTab")
	static let dataInspectorTab: Self = .init("DataInspectorTab")
}

// MARK: File Inspector Outline Cells
extension NSUserInterfaceItemIdentifier {
	static let fileInspectorSeparatorCell: Self = .init("FileInspectorSeparatorCell")
	static let fileInspectorCategoryCell: Self = .init("FileInspectorCategoryCell")
	static let fileInspectorCategoryOptionCell: Self = .init("FileInspectorCategoryOptionCell")
	static let fileInspectorNameAndLocationCell: Self = .init("FileInspectorNameAndLocationCell")
	static let fileInspectorTemplatesCell: Self = .init("FileInspectorTemplatesCell")
	static let fileInspectorDetailsCell: Self = .init("FileInspectorDetailsCell")
}

// MARK: Directory Inspector Outline Cells
extension NSUserInterfaceItemIdentifier {
	static let directoryInspectorSeparatorCell: Self = .init("DirectoryInspectorSeparatorCell")
	static let directoryInspectorCategoryCell: Self = .init("DirectoryInspectorCategoryCell")
	static let directoryInspectorNameAndLocationCell: Self = .init("DirectoryInspectorNameAndLocationCell")
	static let directoryInspectorTemplatesCell: Self = .init("DirectoryInspectorTemplatesCell")
}

// MARK: Parser Inspector Outline Cells
extension NSUserInterfaceItemIdentifier {
	static let parserInspectorSeparatorCell: Self = .init("ParserInspectorSeparatorCell")
	static let parserInspectorSelectionCell: Self = .init("ParserInspectorSelectionCell")
	static let parserInspectorCategoryCell: Self = .init("ParserInspectorCategoryCell")
	static let parserInspectorCategoryWithCheckBoxCell: Self = .init("ParserInspectorCategoryWithCheckBoxCell")
	static let parserInspectorExperimentDetailsCell: Self = .init("ParserInspectorExperimentDetailsCell")
	static let parserInspectorHeaderCell: Self = .init("ParserInspectorHeaderCell")
	static let parserInspectorDataCell: Self = .init("ParserInspectorDataCell")
}

// MARK: Parser Table Columns
extension NSUserInterfaceItemIdentifier {
	static let parserNameColumn: Self = .init("ParserNameColumn")
	static let parserDefaultsColumn: Self = .init("ParserDefaultsColumn")
}

// MARK: Parser Table Cells
extension NSUserInterfaceItemIdentifier {
	static let parserNameCell: Self = .init("ParserNameCell")
	static let parserDefaultsCell: Self = .init("ParserDefaultsCell")
}

// MARK: Data Inspector Outline Cells
extension NSUserInterfaceItemIdentifier {
	static let dataInspectorTableCell: Self = .init("DataInspectorTableCell")
}

// MARK: Graph Template Table Cells
extension NSUserInterfaceItemIdentifier {
	static let graphTemplateNameCell: Self = .init("GraphTemplateNameCell")
}

enum ParsingState: Int {
    case error = -1, started = 0, ready = 1, skipped = 2
}
