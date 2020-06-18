//
//  Parser.swift
//  Graphs
//
//  Created by Connor Barnes on 6/17/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Parser)
public class Parser: NSManagedObject {
	
}

// MARK: Core Data Properties
extension Parser {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Parser> {
		return NSFetchRequest<Parser>(entityName: "Parser")
	}
	
	@NSManaged @objc public var name: String?
	@NSManaged @objc(experimentDetailsStart) public var _experimentDetailsStart: NSNumber?
	@NSManaged @objc(experimentDetailsEnd) public var _experimentDetailsEnd: NSNumber?
	@NSManaged @objc(headerStart) public var _headerStart: NSNumber?
	@NSManaged @objc(headerEnd) public var _headerEnd: NSNumber?
	@NSManaged @objc(dataStart) public var _dataStart: NSNumber?
	@NSManaged public var headerSeparator: String?
	@NSManaged public var dataSeparator: String?
	@NSManaged @objc(footerStart) public var _footerStart: NSNumber?
	@NSManaged @objc(footerLength) public var _footerLength: NSNumber?
	
}

// MARK: Derived Properties
extension Parser {
//	@nonobjc var experimentDetailsStart: Int? { return _experimentDetailsStart?.intValue}
//	@nonobjc var experimentDetailsEnd: Int? { return _experimentDetailsEnd?.intValue }
//	@nonobjc var headerStart: Int? { return _headerStart?.intValue }
//	@nonobjc var headerEnd: Int? { return _headerEnd?.intValue }
//	@nonobjc var dataStart: Int? { return _dataStart?.intValue }
//	@nonobjc var footerStart: Int? { return _footerStart?.intValue }
//	@nonobjc var footerLength: Int? { return _footerLength?.intValue }
//
//	var experimentDetails: (start: Int, end: Int)? {
//		#warning("Not implemented")
//		fatalError("Not implemented")
//	}
//
//	var header: (start: Int, end: Int, separator: CharacterSet)? {
//		#warning("Not implemented")
//		fatalError("Not implemented")
//	}
//
//	var data: (start: Int, separator: CharacterSet)? {
//		#warning("Not implemented")
//		fatalError("Not implemented")
//	}
//
//	var footer: (start: Int?, end: Int?)? {
//
//	}
}
