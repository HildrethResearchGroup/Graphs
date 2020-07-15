//
//  ParserController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

class ParserController {
	private unowned let dataController: DataController
	
	var parsers: [Parser] = []
	
	init(dataController: DataController) {
		self.dataController = dataController
	}
}

// MARK: Helpers
extension ParserController {
	private var context: NSManagedObjectContext {
		return dataController.context
	}
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
	private func parser(for directoryItem: DirectoryItem, fileType: String?) -> Parser? {
		if let file = directoryItem as? File {
			if let fileParser = file.parser {
				// The file has a custom defined parser
				return fileParser
			} else {
				switch file.defaultParserMode {
				case .fileTypeDefault:
					guard let fileType = fileType else { fallthrough }
					return parser(for: fileType)
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
				if let fileType = fileType {
					return parser(for: fileType)
				} else {
					return nil
				}
			} else if let parent = directoryItem.parent {
				return directoryItem.parser ?? parser(for: parent, fileType: fileType)
			} else if let parser = directoryItem.parser {
				return parser
			} else {
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
}
