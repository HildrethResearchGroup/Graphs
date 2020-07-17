//
//  GraphTemplate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

@objc(GraphTemplate)
class GraphTemplate: NSManagedObject { }

extension GraphTemplate {
	/// Returns a fetch request for the `GraphTemplate` entity type.
	/// - Returns: A fetch request for all `GraphTemplate` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<GraphTemplate> {
		return NSFetchRequest<GraphTemplate>(entityName: "GraphTemplate")
	}
	
	@NSManaged var path: URL?
	@NSManaged var name: String
}

extension GraphTemplate {
	var controller: DGController? {
		guard let path = path else { return nil }
		return DGController(contentsOfFile: path.path)
	}
}
