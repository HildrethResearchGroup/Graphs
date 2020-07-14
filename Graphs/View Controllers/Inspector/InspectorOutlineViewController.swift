//
//  InspectorOutlineViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

protocol InspectorOutlineCellItem: Equatable {
	static var outline: [InspectorOutlineCell<Self>] { get }
	static var defaultExpandedCells: [InspectorOutlineCell<Self>] { get }
	
	var cellIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension InspectorOutlineCellItem {
	static var defaultExpandedCells: [InspectorOutlineCell<Self>] {
		return outline.filter { cell in
			switch cell {
			case .header:
				return true
			case .body:
				return false
			}
		}
	}
}

enum InspectorOutlineCell<Item: InspectorOutlineCellItem>: Equatable {
	indirect case header (item: Item, children: [InspectorOutlineCell<Item>])
	case body (item: Item)
}

class InspectorOutlineViewController<Item: InspectorOutlineCellItem>: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	typealias Cell = InspectorOutlineCell<Item>
	
	private func flattenCells(in cells: [Cell]) -> [Cell] {
		var flattened: [Cell] = []
		cells.forEach { cell in
			switch cell {
			case .header(_, let children):
				flattened.append(cell)
				flattened += flattenCells(in: children)
			case .body(_):
				flattened.append(cell)
			}
		}
		return flattened
	}
	
	private func index(for cell: Cell) -> NSNumber {
		return NSNumber(value: flattenCells(in: Item.outline).firstIndex(of: cell)!)
	}
	
	private func cell(for index: NSNumber) -> Cell {
		return flattenCells(in: Item.outline)[index.intValue]
	}
	
	private func cellFromItem(_ item: Any?) -> Cell? {
		guard let item = item else { return nil }
		return cell(for: (item as! NSNumber))
	}
	
	func prepareView(_ view: NSTableCellView, item: Item) {
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		Item.defaultExpandedCells.forEach {
			primaryOutlineView?.expandItem(index(for: $0))
		}
	}
	
	var primaryOutlineView: NSOutlineView? { return nil }
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let cell = cellFromItem(item) else {
			return Item.outline.count
		}
		
		switch cell {
		case .header (_, let children):
			return children.count
		case .body:
			return 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard let cell = cellFromItem(item) else {
			return self.index(for: Item.outline[index])
		}
		
		guard case .header (_, let children) = cell else {
			fatalError("")
		}
		
		return self.index(for: children[index])
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch cellFromItem(item)! {
		case .header:
			return true
		case .body:
			return false
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		let cell = cellFromItem(item)!
		
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
