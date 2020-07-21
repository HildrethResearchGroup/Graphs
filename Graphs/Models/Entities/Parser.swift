//
//  Parser.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation
import CoreData

@objc(Parser)
public class Parser: NSManagedObject {
	@NSNumberWrapped(owner: nil as Parser?, path: \.__dataStart)
	var dataStart: Int?
	@NSNumberWrapped(owner: nil as Parser?, path: \.__experimentDetailsEnd)
	var experimentDetailsEnd: Int?
	@NSNumberWrapped(owner: nil as Parser?, path: \.__experimentDetailsStart)
	var experimentDetailsStart: Int?
	@NSNumberWrapped(owner: nil as Parser?, path: \.__headerEnd)
	var headerEnd: Int?
	@NSNumberWrapped(owner: nil as Parser?, path: \.__headerStart)
	var headerStart: Int?
	
	
	public override func awakeFromFetch() {
		super.awakeFromFetch()
		initializeWrappers()
	}
	
	public override func awakeFromInsert() {
		super.awakeFromNib()
		initializeWrappers()
	}
	
	func initializeWrappers() {
		_dataStart.configure(with: self)
		_experimentDetailsEnd.configure(with: self)
		_experimentDetailsStart.configure(with: self)
		_headerEnd.configure(with: self)
		_headerStart.configure(with: self)
	}
}

// MARK: Generated accessors for directoryItems
extension Parser {

    @objc(addDirectoryItemsObject:)
    @NSManaged public func addToDirectoryItems(_ value: DirectoryItem)

    @objc(removeDirectoryItemsObject:)
    @NSManaged public func removeFromDirectoryItems(_ value: DirectoryItem)

    @objc(addDirectoryItems:)
    @NSManaged public func addToDirectoryItems(_ values: NSSet)

    @objc(removeDirectoryItems:)
    @NSManaged public func removeFromDirectoryItems(_ values: NSSet)

}

// MARK: Core Data Properties
extension Parser {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Parser> {
		return NSFetchRequest<Parser>(entityName: "Parser")
	}
	
	@NSManaged public var name: String
	@objc(dataSeparator)
	@NSManaged public var _dataSeparatorRaw: String
	@objc(headerSeparator)
	@NSManaged public var _headerSeparatorRaw: String
	@NSManaged public var hasFooter: Bool
	@NSManaged public var hasHeader: Bool
	@NSManaged public var hasExperimentDetails: Bool
	@objc(defaultForFileTypes)
	@NSManaged public var _defaultForFileTypes: String
	@objc(dataStart)
	@NSManaged public var __dataStart: NSNumber?
	@objc(experimentDetailsEnd)
	@NSManaged public var __experimentDetailsEnd: NSNumber?
	@objc(experimentDetailsStart)
	@NSManaged public var __experimentDetailsStart: NSNumber?
	@objc(headerEnd)
	@NSManaged public var __headerEnd: NSNumber?
	@objc(headerStart)
	@NSManaged public var __headerStart: NSNumber?
	@NSManaged public var directoryItems: NSSet?
}

// MARK: Derived Properties
extension Parser {
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
	
	var experimentDetailsStartOrGuess: Int {
		experimentDetailsStart = experimentDetailsStart ?? 1
		return experimentDetailsStart!
	}
	
	var experimentDetailsEndOrGuess: Int {
		if let experimentDetailsEnd = experimentDetailsEnd { return experimentDetailsEnd }
		experimentDetailsEnd = experimentDetailsStartOrGuess
		return experimentDetailsEnd!
	}
	
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
	
	var headerEndOrGuess: Int {
		if let headerEnd = headerEnd { return headerEnd }
		headerEnd = headerStartOrGuess
		return headerEnd!
	}
	
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
	var experimentDetailsStartIsValid: Bool {
		guard let sectionStart = experimentDetailsStart else { return false }
		return sectionStart > 0
	}
	
	var experimentDetailsEndIsValid: Bool {
		guard let sectionStart = experimentDetailsStart, let sectionEnd = experimentDetailsEnd else { return false }
		guard sectionEnd >= sectionStart else { return false }
		return sectionEnd > 0
	}
	
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

extension Parser {
	enum Separator: String, CaseIterable {
		case whitespace
		case space
		case tab
		case comma
		case colon
		case semicolon
		
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
	func parse(file: File) -> ParsedFile? {
		guard let url = file.path else { return nil }
		guard let rawContents = try? String.detectingEncoding(ofContents: url).string else { return nil }
		
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
