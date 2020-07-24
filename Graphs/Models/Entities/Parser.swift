//
//  Parser.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation
import CoreData

/// An entity that represents a parser. A parser is capable of parsing text files.
@objc(Parser)
public class Parser: NSManagedObject {
	/// The first line of the file that contains data.
	@NSNumberWrapped(owner: nil as Parser?, path: \.__dataStart)
	var dataStart: Int?
	/// The last line of the file that contains experiment details.
	@NSNumberWrapped(owner: nil as Parser?, path: \.__experimentDetailsEnd)
	var experimentDetailsEnd: Int?
	/// The first line of the file that contains experiment details.
	@NSNumberWrapped(owner: nil as Parser?, path: \.__experimentDetailsStart)
	var experimentDetailsStart: Int?
	/// The last line of the file that contains the header.
	@NSNumberWrapped(owner: nil as Parser?, path: \.__headerEnd)
	var headerEnd: Int?
	/// The first line of the file that contains the header.
	@NSNumberWrapped(owner: nil as Parser?, path: \.__headerStart)
	var headerStart: Int?
	
	public override func awakeFromFetch() {
		// Overriden to initialize the property wrappers. This is not done in an initializer, because Core Data recommends not overriding initializers, but insead overriting awakeFromFetch() and awakeFromInsert()
		super.awakeFromFetch()
		initializeWrappers()
	}
	
	public override func awakeFromInsert() {
		// Overriden to initialize the property wrappers. This is not done in an initializer, because Core Data recommends not overriding initializers, but insead overriting awakeFromFetch() and awakeFromInsert()
		super.awakeFromNib()
		initializeWrappers()
	}
	/// Initializes the NSNumber property wrappers.
	func initializeWrappers() {
		// The property wrappers require `self` to passed to them, so they can't be fully initialized with a default value
		_dataStart.configure(with: self)
		_experimentDetailsEnd.configure(with: self)
		_experimentDetailsStart.configure(with: self)
		_headerEnd.configure(with: self)
		_headerStart.configure(with: self)
	}
}

// MARK: Core Data Properties
extension Parser {
	/// Returns a fetch request for the `Parser` entity type.
	/// - Returns: A fetch request for all `Parser` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Parser> {
		return NSFetchRequest<Parser>(entityName: "Parser")
	}
	/// The name of the parser.
	@NSManaged public var name: String
	/// The raw string value of the data separator. Do not use this value directly, use `dataSeparator` instead.
	@objc(dataSeparator)
	@NSManaged public var _dataSeparatorRaw: String
	/// The raw string value of the header separator. Do not use this value directly, use `headerSeparator` instead.
	@objc(headerSeparator)
	@NSManaged public var _headerSeparatorRaw: String
	/// `true` if the parser ignores data after empty lines, ortherwise `false`.
	///
	/// - Note: An empty line is defined as a line that contains only whitespace after being separated using the data separator.
	@NSManaged public var hasFooter: Bool
	/// `true` if the parser defines starting and ending lines for a header, otherwise `false`.
	@NSManaged public var hasHeader: Bool
	/// `true` if the parser defines starting and ending lines for experiment details, otherwise `false`.
	@NSManaged public var hasExperimentDetails: Bool
	/// A raw string representation of the the file types whose default parsers are this parser. Do not use this value directly, use `deaultForFileTypes` instead.
	@objc(defaultForFileTypes)
	@NSManaged public var _defaultForFileTypes: String
	/// A raw `NSNumber` representation of the first line of the file that contains data. Do not use this value directly, use `dataStart` instead.
	@objc(dataStart)
	@NSManaged public var __dataStart: NSNumber?
	/// A raw `NSNumber` representation of the last line of the file that contains experiment details. Do not use this value directly, use `experimentDetailsEnd` instead.
	@objc(experimentDetailsEnd)
	@NSManaged public var __experimentDetailsEnd: NSNumber?
	/// A raw `NSNumber` representation of the first line of the file that contains experiment details. Do not use this value directly, use `experimentDetailsStart` instead.
	@objc(experimentDetailsStart)
	@NSManaged public var __experimentDetailsStart: NSNumber?
	/// A raw `NSNumber` representation of the last line of the file that contains the header. Do not use this value directly, use `headerEnd` instead.
	@objc(headerEnd)
	@NSManaged public var __headerEnd: NSNumber?
	/// A raw `NSNumber` representation of the first line of the file that contains the header. Do not use this value directly, use `headerStart` instead.
	@objc(headerStart)
	@NSManaged public var __headerStart: NSNumber?
	/// The directory items who have explicitly set this parser as their default parser. This does not include folders or files who are using their parent folder's default parser or the default parser for their file type.
	@NSManaged public var directoryItems: NSSet?
}

// MARK: Generated accessors for directoryItems
extension Parser {
	/// Sets a directory item's parser to be this parser.
	@objc(addDirectoryItemsObject:)
	@NSManaged public func addToDirectoryItems(_ value: DirectoryItem)
	/// Removes this parser as the given directory item's default parser.
	///
	/// If the directory item's default parser was not this parser, this will do nothing. Otherwise, the directory item's default parser will be `nil`; for files, the default parser will fallback on the parent folder's default or the default parser for the file's file type.
	///
	/// - Note: The directory item may still use this parser as its default parser if its parent directory uses this parser, or if the directory item is a file, and this is the default parser for the file's file type.
	@objc(removeDirectoryItemsObject:)
	@NSManaged public func removeFromDirectoryItems(_ value: DirectoryItem)
	/// Sets a set of directory items' parsers to be this parser.
	@objc(addDirectoryItems:)
	@NSManaged public func addToDirectoryItems(_ values: NSSet)
	/// Removes this parser as the given directory items' default parser.
	///
	/// If a directory item's default parser in the set was not this parser, this will do nothing for that item. Otherwise, the directory item's default parser will be `nil`; for files, the default parser will fallback on the parent folder's default or the default parser for the file's file type.
	///
	/// - Note: Each directory item may still use this parser as its default parser if its parent directory uses this parser, or if the directory item is a file, and this is the default parser for the file's file type.
	@objc(removeDirectoryItems:)
	@NSManaged public func removeFromDirectoryItems(_ values: NSSet)
}

// MARK: Custom Accessors
extension Parser {
	/// The separator that separates columns of data.
	var dataSeparator: Separator {
		get {
			guard let separator = Separator(rawValue: _dataSeparatorRaw) else {
				print("[WARNING] Invalid separator string: \(_dataSeparatorRaw) -- Replacing with valid \"comma\".")
				_dataSeparatorRaw = Separator.comma.rawValue
				return Separator.comma
			}
			return separator
		}
		set {
			_dataSeparatorRaw = newValue.rawValue
		}
	}
	/// The separator that separates columns in the header.
	var headerSeparator: Separator {
		get {
			guard let separator = Separator(rawValue: _headerSeparatorRaw) else {
				print("[WARNING] Invalid separator string: \(_dataSeparatorRaw) -- Replacing with valid \"comma\".")
				_headerSeparatorRaw = Separator.comma.rawValue
				return Separator.comma
			}
			return separator
		}
		set {
			_headerSeparatorRaw = newValue.rawValue
		}
	}
	/// The file extensions of the file types whose default parser is this parser.
	var defaultForFileTypes: [String] {
		get {
			return _defaultForFileTypes.components(separatedBy: ",")
		}
		set {
			_defaultForFileTypes = newValue
				.map { $0.filter { !$0.isWhitespace } }
				.joined(separator: ",")
		}
	}
	/// The first line of the experiment details, or a guess.
	///
	/// - Note: Accessing this property will assign a value to `experimentDetailsStart` if it is `nil`.
	var experimentDetailsStartOrGuess: Int {
		experimentDetailsStart = experimentDetailsStart ?? 1
		return experimentDetailsStart!
	}
	/// The last line of the experiment details, or a guess.
	///
	/// - Note: Accessing this property will assign a value to `experimentDetailsEnd` if it is `nil`.
	var experimentDetailsEndOrGuess: Int {
		if let experimentDetailsEnd = experimentDetailsEnd { return experimentDetailsEnd }
		experimentDetailsEnd = experimentDetailsStartOrGuess
		return experimentDetailsEnd!
	}
	/// The first line of the header, or a guess.
	///
	/// - Note: Accessing this property will assign a value to `headerStart` if it is `nil`.
	var headerStartOrGuess: Int {
		if let headerStart = headerStart { return headerStart }
		if hasExperimentDetails {
			headerStart = experimentDetailsEndOrGuess + 1
			return headerStart!
		} else {
			headerStart = 1
			return headerStart!
		}
	}
	/// The last line of the header, or a guess.
	///
	/// - Note: Accessing this property will assign a value to `headerEnd` if it is `nil`.
	var headerEndOrGuess: Int {
		if let headerEnd = headerEnd { return headerEnd }
		headerEnd = headerStartOrGuess
		return headerEnd!
	}
	/// The first line of the data, or a guess.
	///
	/// - Note: Accessing this property will assign a value to `dataStart` if it is `nil`.
	var dataStartOrGuess: Int {
		if let dataStart = dataStart { return dataStart }
		if hasHeader {
			dataStart = headerEndOrGuess + 1
			return dataStart!
		} else if hasExperimentDetails {
			dataStart = experimentDetailsEndOrGuess + 1
			return dataStart!
		} else {
			dataStart = 1
			return dataStart!
		}
	}
}

// MARK: Validations
extension Parser {
	/// `true` if the starting line for the experiment details is valid, otherwise `false`.
	///
	/// The starting line for the experiment details is valid if it is not `nil` and begins on line `1` or later.
	var experimentDetailsStartIsValid: Bool {
		guard let sectionStart = experimentDetailsStart else { return false }
		return sectionStart > 0
	}
	/// `true` if the ending line for the experiment details is valid, otherwise `false`.
	///
	/// The ending line for the experiment details is valid if it is not `nil` and begins on or after the starting line for the experiment details.
	var experimentDetailsEndIsValid: Bool {
		guard let sectionStart = experimentDetailsStart, let sectionEnd = experimentDetailsEnd else { return false }
		guard sectionEnd >= sectionStart else { return false }
		return sectionEnd > 0
	}
	/// `true` if the starting line for the header is valid, otherwise `false`.
	///
	/// The starting line for the header is valid if it is not `nil` and begins before or after the experiment details section (if there is one) or otherwise begins on line `1` or later.
	var headerStartIsValid: Bool {
		guard let sectionStart = headerStart else { return false }
		if hasExperimentDetails {
			guard let start = experimentDetailsStart, let end = experimentDetailsEnd else { return false }
			// The header section starts within the experiment details section
			if end >= start {
				if (start...end).contains(sectionStart) { return false }
			}
		}
		return sectionStart > 0
	}
	/// `true` if the starting line for the header is valid, otherwise `false`.
	///
	/// The ending line for the header is valid if it is not `nil` and the header range (`headerStart...headerEnd`) does not fall within the experiment details range (`experimentDetailsStart...experimentDetailsEnd`) if there is an experiment details section and the header end is on or after the header start line.
	var headerEndIsValid: Bool {
		guard let sectionStart = headerStart, let sectionEnd = headerEnd else { return false }
		if hasExperimentDetails {
			guard let start = experimentDetailsStart, let end = experimentDetailsEnd else { return false }
			// The header section intersects the experiment details section
			if end >= start && sectionEnd >= sectionStart {
				if (start...end).overlaps(sectionStart...sectionEnd) { return false }
			}
		}
		guard sectionEnd >= sectionStart else { return false }
		return sectionEnd > 0
	}
	/// `true` if the starting line for the data is valid, otherwise `false`.
	///
	/// The starting line for the data is valid if it starts after both the experiment details and header sections (if they exist) and begins on or after line `1`.
	var dataStartIsValid: Bool {
		guard let dataStart = dataStart else { return false }
		if hasExperimentDetails {
			guard let start = experimentDetailsStart, let end = experimentDetailsEnd else { return false }
			// The start of the data is within the experiment details section
			if end >= start {
				if (start...end).contains(dataStart) { return false }
			}
			// The experiment details section is after the start of the data
			if start >= dataStart { return false }
		}
		if hasHeader {
			guard let start = headerStart, let end = headerEnd else { return false }
			// The start of the data is within the header section
			if end >= start {
				if (start...end).contains(dataStart) { return false }
			}
			// The header section is after the start of the data
			if start >= dataStart { return false }
		}
		return dataStart > 0
	}
}

// MARK: Parser Separator
extension Parser {
	// The enum has an associaed value of string, so that the separator can be encoded and decoded as a string trivally for Core Data, and so that additional cases can be added easily in the future.
	/// A character or character set that can divide a row string into columns.
	enum Separator: String, CaseIterable {
		/// Seperates the string by any amount of whitespace.
		case whitespace
		/// Separates the string by a single space.
		case space
		/// Separates the string by a single tab.
		case tab
		/// Separates the string by a single comma.
		case comma
		/// Separates the string by a single colon.
		case colon
		/// Separates the string by a single semicolon.
		case semicolon
		
		/// The set of characters to be used to separate a row into columns.
		var characterSet: CharacterSet {
			switch self {
			case .whitespace:
				return .whitespaces
			case .space:
				return CharacterSet(charactersIn: " ")
			case .tab:
				return CharacterSet(charactersIn: "\t")
			case .comma:
				return CharacterSet(charactersIn: ",")
			case .colon:
				return CharacterSet(charactersIn: ":")
			case .semicolon:
				return CharacterSet(charactersIn: ";")
			}
		}
	}
}

// MARK: Parsing
extension Parser {
	/// Parses the given file.
	/// - Parameter file: The file to parse.
	/// - Returns: The parsed file, or `nil` if the file couldn't be parsed.
	func parse(file: File) -> ParsedFile? {
		// TODO: Add a caching mechanism, because this is called multiple times and can be an expensive operation
		guard let url = file.path else { return nil }
		// The file could use any encoding, so try to detect the encoding
		guard let rawContents = try? String.detectingEncoding(ofContents: url).string else { return nil }
		// Windows encodes newlines as "\r\n", while unix and unix-like systems encodes newlines as "\n". The file's contents will be separated into lines using String.components(separatedBy:) which treats \r and \n each as a new line. Because of this, we replace all instances of "\r\n" with a single "\n".
		let contents = rawContents.replacingOccurrences(of: "\r\n", with: "\n")
		let lines = contents.components(separatedBy: .newlines)
		// Try to get the experiment details. If there are experiment details enabled but the start and/or end is invalid then return nil
		guard let experimentDetails = { () -> String? in
			if hasExperimentDetails {
				guard experimentDetailsStartIsValid && experimentDetailsEndIsValid else { return nil }
				// The index of each line is one less than its number. The line number is shown to the user rather than the line index, because for non-programmers 1-based indexing is more natural
				// The two values can be unsafely unwrapped because if either was nil, then the previous line would return false
				let start = experimentDetailsStart! - 1
				let end = experimentDetailsEnd! - 1
				
				if lines.count <= end {
					if lines.count <= start {
						// The file ends before the start of the experiment details, so there are no experiment details -- this is displayed in a text view, so an empty string is fine compared to nil
						return ""
					} else {
						// The file ends before the end of the experiment details, so just return the experiment details to the end of the file
						return lines[start..<lines.count].joined(separator: "\n")
					}
				}
				// The entire section is within the file
				return lines[start...end].joined(separator: "\n")
			} else {
				// No experiment details -- this is displayed in a text view, so an empty string is fine compared to nil
				return ""
			}
			}() else { return nil}
		
		// Try to get the header. If the header is enabled but the start and/or end is invalid then return nil
		guard let header = { () -> [[String]]? in
			if hasHeader {
				guard headerStartIsValid && headerEndIsValid else { return nil }
				
				let cells = lines.map {
					$0.components(separatedBy: headerSeparator.characterSet)
						// If whitespace is used, there will be a split between each whitespcae character -- to prevent this, remove empty cells
						.filter { headerSeparator == .whitespace ? $0 != "" : true }
				}
				
				// The index of each line is one less than its number. The line number is shown to the user rather than the line index, because for non-programmers 1-based indexing is more natural
				// The two values can be unsafely unwrapped because if either was nil, then the previous line would return false
				let start = headerStartOrGuess - 1
				let end = headerEndOrGuess - 1
				
				if cells.count <= end {
					if cells.count <= start {
						// The header starts after the end of the file
						return []
					} else {
						// The header ends after the end of the file, so just include the rows from start to the end of the file
						return Array(cells[start..<cells.count])
					}
				} else {
					// The entire section is in the file
					return Array(cells[start...end])
				}
			} else {
				// No header
				return []
			}
			}() else { return nil }
		
		// Try to get the data. If the data start is invalid then return nil
		guard let data = { () -> [[String]]? in
			guard dataStartIsValid else { return nil }
			
			let cells = lines.map {
				$0.components(separatedBy: dataSeparator.characterSet)
					// If whitespace is used, there will be a split between each whitespcae character -- to prevent this, remove empty cells
					.filter { dataSeparator == .whitespace ? $0 != "" : true }
			}
			// The index of each line is one less than its number. The line number is shown to the user rather than the line index, because for non-programmers 1-based indexing is more natural
			// This value can be unsafely unwrapped because if it was nil, then the previous line would return false
			let start = dataStart! - 1
			guard start < cells.count else { return [] }
			
			let end: Int = {
				if hasFooter {
					// If there is a footer, stop collecting data after the first empty line after the data begins
					let searchCells = cells[start..<cells.count]
					let lineIsEmpty: ([String]) -> Bool = { row -> Bool in
						return row.allSatisfy { $0 == "" }
					}
					let firstEmptyLine = searchCells.firstIndex(where: lineIsEmpty)
					return firstEmptyLine ?? searchCells.firstIndex(of: []) ?? cells.count
				} else {
					// Otherwise there is no footer, so collect data until the end of the file
					return cells.count
				}
			}()
			
			if cells.count <= end {
				// The data ends after the end of the file (this shouldn't ever happen) so just return the lines from start to the end of the file
				return Array(cells[start..<cells.count])
			} else {
				// The data ends within the file, so return the whole range of lines
				return Array(cells[start..<end])
			}
			}() else { return nil }
		
		// The number of columns is used to determine how many columns to add to an NSTableView. There can be a variable number of columns, so return the maximum number of columns in the header and data sections
		// The number of columns is calculated here to prevent having to recalculate it from within the tableview when updates are needed
		let headerNumberOfColumns = header.max { $0.count < $1.count }?.count ?? 0
		let dataNumberOfColumns = data.max { $0.count < $1.count }?.count ?? 0
		let numberOfColumns = max(headerNumberOfColumns, dataNumberOfColumns)
		
		return ParsedFile(experimentDetails: experimentDetails,
											header: header,
											data: data,
											numberOfColumns: numberOfColumns)
	}
}
