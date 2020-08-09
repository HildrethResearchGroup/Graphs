//
//  ParserController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

class ParserController {
	/// The data controller which controls the Core Data store.
	private unowned let dataController: DataController
	/// The parsers that have been created.
	var parsers: [Parser] = []
	/// Creates a file controller from a data controller.
	/// - Parameter dataController: The data controller to use.
	init(dataController: DataController) {
		self.dataController = dataController
	}
}

// MARK: Helpers
extension ParserController {
	/// The Core Data context.
	private var context: NSManagedObjectContext {
		return dataController.context
	}
	/// Returns the default parser for the given file type if one exists.
	///
	/// - Note: If multiple parsers exist for the given file type, then one of those parsers will be returned, which one is not guaranteed to be the same accross subsequent calls.
	/// - Parameter fileType: The file extension to find the default parser of.
	/// - Returns: The default parser for the given file if one exists.
	private func parser(for fileType: String) -> Parser? {
		let parsers = defaultParsers(forFileType: fileType)
		switch parsers.count {
		case 0, 1:
			// If there is one match it will return that parser, otherwise if there is no match it will return nil
			return parsers.first
		default:
			// Multiple parsers match -- which one will be used is ambiguous
			print("[WARNING] Multiple default parsers found for file extension \(fileType). Which one will be used is not guaranteed.")
			return parsers.first
		}
	}
	// This is a helper function which allows specifying the file type, so that if none of a file's ancestors have a default parser selected, the default parser for the file's file type can be used instead. This function is implemented so that it is tail recursive, which could not be achieved if it did not have the extra parameter.
	/// The parser to use for the given directory item.
	///
	///	See `ParserController.parser(for:)`.
	///
	/// - Parameters:
	///   - directoryItem: The directory item to find the parser for.
	///   - fileType: The file extension of the file if seaching for a file.
	/// - Returns: The parser to use for the given directory item.
	private func parser(for directoryItem: DirectoryItem, fileType: String?) -> Parser? {
		if let file = directoryItem as? File {
			if let fileParser = file.parser {
				// The file has a custom defined parser
				return fileParser
			} else {
				switch file.defaultParserMode {
				case .fileTypeDefault:
					// If there is no default parser for the file's file type, then use the folder default method instead (which is the next switch case, so fallthrough -- consequently this is the first time that I have ever needed to use the fallthough keyword in Swift)
					guard let fileType = fileType else { fallthrough }
					guard let fileTypeDefault = parser(for: fileType) else { fallthrough }
					return fileTypeDefault
				case .folderDefault:
					guard let parent = directoryItem.parent else {
						print("[WARNING] Trying to find default parser for parent directory of a file with no parent directory.")
						return nil
					}
					return parser(for: parent, fileType: fileType)
				}
			}
		} else {
			if directoryItem == dataController.rootDirectory {
				// None of the item's ancestors had a default parser defined, so see if there is a default for the file's file type instead to fall back on.
				if let fileType = fileType {
					return parser(for: fileType)
				} else {
					return nil
				}
			} else if let parent = directoryItem.parent {
				// If the item has a parent, return its default parser if this item doesn't have a default specified.
				return directoryItem.parser ?? parser(for: parent, fileType: fileType)
			} else {
				// Note that the case if let parser = directoryItem.parser { ... } doesn't need to be checked for, becuase every directory item will have a parent except for the root directory, which has already been checked against.
				print("[WARNING] Trying to find default parser for parent directory of a non-root directory with no parent directory.")
				return nil
			}
		}
	}
}

// MARK: Interface
extension ParserController {
	/// Loads all parsers from the CoreData store.
	func loadParsers() {
		let fetchRequest: NSFetchRequest<Parser> = Parser.fetchRequest()
		do {
			parsers = try context.fetch(fetchRequest)
		} catch {
			print("[ERROR] Failed to load parsers from Core Data store: \(error)")
		}
	}
	/// Creates a new parser.
	/// - Returns: A new parser.
	@discardableResult
	func createParser() -> Parser {
		let parser = Parser(context: context)
		parsers.append(parser)
		dataController.setNeedsSaved()
		return parser
	}
	/// Removes the given parser.
	/// - Parameter parser: The parser to remove.
	func remove(parser: Parser) {
		parsers.removeAll { $0 === parser }
		context.delete(parser)
		dataController.setNeedsSaved()
	}
	/// The parser to use for the given directory item.
	/// - Parameter directoryItem: The directory item to find the parser for.
	/// - Returns: The parser to use for the given file, or the default parser for the given directory.
	///
	/// The parser for a given file is determined as follows: if the file has a custom parser, that parser is used. Otherwise the file has a toggle for which parser to choose from:
	///
	/// 1. *By folder:* the parser of the closet ansestor's default parser is used.
	/// 2. *By file type:* the default parser of the file's file type is used.
	///
	/// If there is no parser for the file's chosen method (by folder/file type) then the other method is used. If niether method has a default, then the file has no default parser.
	func parser(for directoryItem: DirectoryItem) -> Parser? {
		let fileExtension = (directoryItem as? File)?.fileExtension
		return parser(for: directoryItem, fileType: fileExtension)
	}
	/// Returns the default parsers for the given file type.
	/// - Parameter fileType: The file type (extension) to find the default parser for.
	/// - Returns: The default parser for the given file type, or `nil` if there isn't one.
	func defaultParsers(forFileType fileType: String) -> [Parser] {
		return parsers.filter { $0.defaultForFileTypes.contains(fileType) }
	}
	/// Renames the given parser.
	/// - Parameters:
	///   - parser: The parser to rename.
	///   - newName: The new name of the parser.
	func rename(parser: Parser, to newName: String) {
		parser.name = newName
		dataController.setNeedsSaved()
	}
	/// Changes the default file types for the given parser.
	/// - Parameters:
	///   - parser: The parser to change its default file types.
	///   - fileTypes: The extensions of the file types that should default to this parser.
	func changeDefaultFileTypes(for parser: Parser, to fileTypes: [String]) {
		parser.defaultForFileTypes = fileTypes
		dataController.setNeedsSaved()
	}
	/// Imports a parser from the given url.
	/// - Parameters:
	///   - notify: If `true`, a notification will be sent to reload the parser table.
	///   - tableView: The table view to animate the changes to.
	/// - Returns: The parser if it could be imported, otherwise `nil`.
	@discardableResult
	func importParser(from url: URL, notify: Bool = true) -> Parser? {
		do {
			let data = try Data(contentsOf: url)
			let storage = try PropertyListDecoder().decode(Parser.FileStorage.self, from: data)
			
			// Check if there is an existing parser with the same storage -- if there is, then use that one instead
			if let name = storage.name {
				let candidates = dataController.parsers.filter { $0.name == name }
				if let existing = candidates.first(where: { parser -> Bool in
					let existingStorage = Parser.FileStorage(from: parser)
					return storage == existingStorage
				}) {
					return existing
				}
			}
			
			let parser = dataController.createParser()
			parser.loadFrom(fileStorage: storage)
			
			if notify {
				NotificationCenter.default.post(name: .didImportParser, object: parser)
			}
			
			return parser
		} catch {
			print("[ERROR] Failed to import parser: \(error)")
			return nil
		}
	}
}
