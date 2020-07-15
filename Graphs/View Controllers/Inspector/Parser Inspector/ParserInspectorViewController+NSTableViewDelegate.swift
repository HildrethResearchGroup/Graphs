//
//  ParserInspectorViewController+NSTableViewDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension ParserInspectorViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return dataController?.parsers.count ?? 0
	}
}

extension ParserInspectorViewController: NSTableViewDelegate {
//	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//		
//	}
}
