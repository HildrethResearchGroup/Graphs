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

extension Parser {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Parser> {
		return NSFetchRequest<Parser>(entityName: "Parser")
	}
	
	@NSManaged public var dataSeparator: String?
	@NSManaged public var headerSeparator: String?
	@NSManaged public var hasFooter: Bool
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
}
