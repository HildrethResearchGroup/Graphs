//
//  InspectorOutlineViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

protocol InspectorOutlineCellItem {
	static var outline: [InspectorOutlineCell<Self>] { get }
	
	var cellIdentifier: NSUserInterfaceItemIdentifier { get }
}

enum InspectorOutlineCell<Item: InspectorOutlineCellItem> {
	indirect case header (item: Item, children: [InspectorOutlineCell<Item>])
	case body (item: Item)
}

class InspectorOutlineViewController<Item: InspectorOutlineCellItem>: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	typealias Cell = InspectorOutlineCell<Item>
	
	func prepareView(_ view: NSTableCellView, item: Item) {
		
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let item = item as? Cell else {
			return Item.outline.count
		}
		
		switch item {
		case .header (_, let children):
			return children.count
		case .body:
			return 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard let item = item as? Cell else {
			return Item.outline[index]
		}
		
		guard case .header (_, let children) = item else {
			fatalError("")
		}
		
		return children[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item as! Cell {
		case .header:
			return true
		case .body:
			return false
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let cell = item as? Cell else { return nil }
		
		let item: Item = {
			switch cell {
			case .header(let item, _):
				return item
			case .body(let item):
				return item
			}
		}()
		
		let view = outlineView.makeView(withIdentifier: item.cellIdentifier, owner: self) as! NSTableCellView
		
		prepareView(view, item: item)
		
		return view
	}
}
