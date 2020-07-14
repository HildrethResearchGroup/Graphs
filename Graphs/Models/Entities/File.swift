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
}

// MARK: Derived Properties
extension File {
	var fileExtension: String? {
		guard let substring = path?.lastPathComponent.split(separator: ".").last else {
			return nil
		}
		return String(substring)
	}
	
	var fileAttributes: [FileAttributeKey: Any]? {
		guard let url = path?.path else { return nil }
		
		return try? FileManager.default.attributesOfItem(atPath: String(url))
	}
	
	var dateCreated: Date? {
		return fileAttributes?[FileAttributeKey.creationDate] as? Date
	}
	
	var dateModified: Date? {
		return fileAttributes?[FileAttributeKey.modificationDate] as? Date
	}
	
	var fileSize: Int? {
		return (fileAttributes?[FileAttributeKey.size] as? NSNumber)?.intValue
	}
	
	var fileSizeString: String {
		guard let fileSize = fileSize else { return "" }
		
		let bytes = Measurement(value: Double(fileSize),
														unit: UnitInformationStorage.bytes)
		
		let byteFormatter = ByteCountFormatter()
		byteFormatter.includesUnit = true
		byteFormatter.zeroPadsFractionDigits = true
		
		return byteFormatter.string(from: bytes)
	}
}

// MARK: Sorting
extension File {
	enum SortKey: String {
		case displayName
		case collectionName
		case dateCreated
		case dateModified
		case size
	}
}
