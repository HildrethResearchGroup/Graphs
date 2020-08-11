//
//  URL.swift
//  Graphs
//
//  Created by Connor Barnes on 8/10/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension URL {
	/// Returns true if the url is a file system container. (Packages are not considered containers)
	var isFolder: Bool {
		guard let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) else { return false }
		
		return (resources.isDirectory ?? false) && !(resources.isPackage ?? false)
	}
}
