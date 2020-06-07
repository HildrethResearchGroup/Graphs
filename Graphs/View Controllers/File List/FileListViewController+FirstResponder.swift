//
//  FileListViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 6/7/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileListViewController {
	@objc func delete(_ sender: Any?) {
		removeSelectedFiles()
	}
}
