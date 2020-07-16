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
