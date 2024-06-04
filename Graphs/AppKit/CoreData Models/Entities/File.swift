//
//  File+CoreDataClass.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//
//

import Foundation
import CoreData

/// An entity that represents a data file on the system.
///
/// This should always point to an actual file on the system, even if its parent does not.
@objc(File)
public class File: DirectoryItem { }

// MARK: Core Data Properties
extension File {
	/// Returns a fetch request for the `File` entity type.
	/// - Returns: A fetch request for all `File` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<File> {
		return NSFetchRequest<File>(entityName: "File")
	}
	/// The raw integer representation of the default parsing mode. Do not use this directly, instead use `defaultParserMode`.
	@objc(parserDefaultMode)
	@NSManaged var _parserDefaultModeRaw: Int64
	/// A user inputed string describing the data.
	@NSManaged var customDetails: String
	/// The date that the file was imported.
	@NSManaged public var dateImported: Date?
}

// MARK: Derived Properties
extension File {
	/// The method for determing the parser for a file without an explicit parser set.
	///
	/// - Note: If the method chosen cannot determine a parser, the other method is used to determine the parser.
	enum DefaultParserMode: Int64 {
		/// The parser is chosen base of the file's nearest ansestor's default parser.
		case folderDefault
		/// The parser is chosen by the default parser of the file's file type.
		case fileTypeDefault
	}
	/// The method for determining the file's parser when no explict parser is given.
	var defaultParserMode: DefaultParserMode {
		get {
			return DefaultParserMode(rawValue: _parserDefaultModeRaw) ?? .folderDefault
		}
		set {
			_parserDefaultModeRaw = newValue.rawValue
		}
	}
	/// The file's file extension.
	///
	/// The file extension does not include a period. For example, the file `"example.txt"` would return `"txt"` for this property.
	var fileExtension: String? {
		guard let substring = path?.lastPathComponent.split(separator: ".").last else {
			return nil
		}
		return String(substring)
	}
	/// The file attribute dictionary for the file.
	var fileAttributes: [FileAttributeKey: Any]? {
		guard let url = path?.path else { return nil }
		
		return try? FileManager.default.attributesOfItem(atPath: String(url))
	}
	/// The date the file created.
	var dateCreated: Date? {
		return fileAttributes?[FileAttributeKey.creationDate] as? Date
	}
	/// The data the file was last modified.
	var dateModified: Date? {
		return fileAttributes?[FileAttributeKey.modificationDate] as? Date
	}
	/// The size of the file in bytes.
	var fileSize: Int? {
		return (fileAttributes?[FileAttributeKey.size] as? NSNumber)?.intValue
	}
	/// The size of the file as a user readable string.
	///
	/// This property converts the file size into the appropriate unit.
	var fileSizeString: String {
		guard let fileSize = fileSize else { return "" }
		
		let bytes = Measurement(value: Double(fileSize),
														unit: UnitInformationStorage.bytes)
		
		let byteFormatter = ByteCountFormatter()
		// The unit varies based off the size of the file, so always display the unite
		byteFormatter.includesUnit = true
		// Zero pad because the size is listed in a column, and all of the rows should align
		byteFormatter.zeroPadsFractionDigits = true
		
		return byteFormatter.string(from: bytes)
	}
}

// MARK: Sorting
extension File {
	/// The key to sort the files by.
	enum SortKey: String {
		/// Sort by the file's display name.
		case displayName
		/// Sort by the name of the file's parent directory.
		case collectionName
		/// Sort by the file's creation date.
		case dateCreated
		/// Sort by the file's date last modified.
		case dateModified
		/// Sort by the file's size.
		case size
	}
}
