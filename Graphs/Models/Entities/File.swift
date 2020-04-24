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
