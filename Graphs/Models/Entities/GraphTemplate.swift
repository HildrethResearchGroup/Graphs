//
//  GraphTemplate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import CoreData

@objc(GraphTemplate)
public class GraphTemplate: NSManagedObject { }

extension GraphTemplate {
	/// Returns a fetch request for the `GraphTemplate` entity type.
	/// - Returns: A fetch request for all `GraphTemplate` entities.
	@nonobjc public class func fetchRequest() -> NSFetchRequest<GraphTemplate> {
		return NSFetchRequest<GraphTemplate>(entityName: "GraphTemplate")
	}
	
	@NSManaged var path: URL?
	@NSManaged var name: String
}

// MARK: Generated accessors for directoryItems
extension GraphTemplate {

    @objc(addDirectoryItemsObject:)
    @NSManaged public func addToDirectoryItems(_ value: DirectoryItem)

    @objc(removeDirectoryItemsObject:)
    @NSManaged public func removeFromDirectoryItems(_ value: DirectoryItem)

    @objc(addDirectoryItems:)
    @NSManaged public func addToDirectoryItems(_ values: NSSet)

    @objc(removeDirectoryItems:)
    @NSManaged public func removeFromDirectoryItems(_ values: NSSet)

}

extension GraphTemplate {
	var controller: DGController? {
		guard let path = path else { return nil }
		return DGController(contentsOfFile: path.path)
	}
}
