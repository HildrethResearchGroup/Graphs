//
//  InspectorOutlineViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which displays an outline view with a static set of items.
class InspectorOutlineViewController<Item: InspectorOutlineCellItem>: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	typealias Cell = InspectorOutlineCell<Item>
	/// Returns all of the outline view's cells in an array.
	/// - Parameter cells: The cells to flatten into an array.
	/// - Returns: The outline view's cells flattened into an array.
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
	// NSOutlineView requires a data source method that returns the outline view's items. The actual items are a Swift enum type with associated values, which was not working with NSOutlineView (written in Objective-C), so the enum has to be converted into a type that works well with Objective-C, and that can be converted back into the cell. NSNumber is used because it is easy to map the cell to and from the flattened index of the cell.
	/// Returns the flattened index for the given cell.
	private func index(for cell: Cell) -> NSNumber {
		return NSNumber(value: flattenCells(in: Item.outline).firstIndex(of: cell)!)
	}
	/// Returns the cell for the given flattened index.
	private func cell(for index: NSNumber) -> Cell {
		return flattenCells(in: Item.outline)[index.intValue]
	}
	/// Returns the cell for the given outline view item.
	private func cellFromItem(_ item: Any?) -> Cell? {
		guard let item = item else { return nil }
		return cell(for: (item as! NSNumber))
	}
	// Overrided by subclasses to customize cells.
	/// Prepares the given table cell view with the given item's data.
	func prepareView(_ view: NSTableCellView, item: Item) { }
	/// The static outline view which is managed by `InspectorOutlineViewController`.
	var primaryOutlineView: NSOutlineView? { return nil }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		Item.defaultExpandedCells.forEach {
			primaryOutlineView?.expandItem(index(for: $0))
		}
	}
	
	// Because this class uses generics, conformace to NSOutlineViewDataSource and NSOutlineViewDelegate cannot be done in an extension, nor can the methods be placed in an extension
	// MARK: NSOutlineViewDataSource
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let cell = cellFromItem(item) else {
			// item is nil for the top level. Return the number of cells in the Item type's outline.
			return Item.outline.count
		}
		
		switch cell {
		case .header (_, let children):
			// Header cells' children are placed one row deeper
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
			fatalError("InspectorOutlineViewController's outline view asked for a body cell's child, but body cells can't have children.")
		}
		
		// NSOutlineView requires a data source method that returns the outline view's items. The actual items are a Swift enum type with associated values, which was not working with NSOutlineView (written in Objective-C), so the enum has to be converted into a type that works well with Objective-C, and that can be converted back into the cell. NSNumber is used because it is easy to map the cell to and from the flattened index of the cell.
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
	
	// MARK: NSOutlineViewDelegate
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		// NSOutlineView requires a data source method that returns the outline view's items. The actual items are a Swift enum type with associated values, which was not working with NSOutlineView (written in Objective-C), so the enum has to be converted into a type that works well with Objective-C, and that can be converted back into the cell. NSNumber is used because it is easy to map the cell to and from the flattened index of the cell.
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
		
		// Allow subclasses to customize the view before it is displayed.
		prepareView(view, item: item)
		
		return view
	}
}

// MARK: InspectorOutlineCellItem
/// A type which describes the static layout of an outline view.
protocol InspectorOutlineCellItem: Equatable {
	/// The hierarchy of the cells to be displayed.
	static var outline: [InspectorOutlineCell<Self>] { get }
	/// The header cells which should be expanded by default.
	///
	/// By default, all top level headers are expanded.
	static var defaultExpandedCells: [InspectorOutlineCell<Self>] { get }
	/// The identifier for the given cell type.
	var cellIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension InspectorOutlineCellItem {
	static var defaultExpandedCells: [InspectorOutlineCell<Self>] {
		// By default expand all top level headers.
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

// MARK: InspectorOutlineCell
/// An individual cell in a static outline view.
enum InspectorOutlineCell<Item: InspectorOutlineCellItem>: Equatable {
	/// A cell that has children which can be collapsed and expanded by the user.
	///
	/// - `item`: The item to display in the cell.
	/// - `children`: The item's children.
	indirect case header (item: Item, children: [InspectorOutlineCell<Item>])
	/// A cell that has no children.
	///
	/// - `item`:  The item to dispaly in the cell.
	case body (item: Item)
}
