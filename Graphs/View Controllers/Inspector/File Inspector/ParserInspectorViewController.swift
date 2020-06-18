//
//  ParserInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/17/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class ParserInspectorViewController: InspectorOutlineViewController<ParserOutlineItem> {
	@IBOutlet weak var outlineView: NSOutlineView!
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	override func prepareView(_ view: NSTableCellView, item: ParserOutlineItem) {
		switch item {
		case .separator:
			return
		case .parserListHeader:
			view.textField?.stringValue = "Available Parsers"
		case .parserListBody:
			#warning("Not implemented")
			break
		case .experimentDetailsHeader:
			let view = view as! InspectorCategoryButtonCell
			view.button.title = "Experiment Details"
		case .experimentDetailsBody:
			#warning("Not implemented")
			break
		case .headerHeader:
			let view = view as! InspectorCategoryButtonCell
			view.button.title = "Header"
		case .headerBody:
			#warning("Not implemented")
			break
		case .dataHeader:
			let view = view as! InspectorCategoryButtonCell
			view.button.title = "Data"
		case .dataBody:
			#warning("Not implemented")
			break
		case .footerHeader:
			let view = view as! InspectorCategoryButtonCell
			view.button.title = "Footer"
		case .footerBody:
			#warning("Not implemented")
			break
		}
	}
}

// MARK: OutlineViewItems
enum ParserOutlineItem: InspectorOutlineCellItem {
	case separator
	case parserListHeader
	case parserListBody
	case experimentDetailsHeader
	case experimentDetailsBody
	case headerHeader
	case headerBody
	case dataHeader
	case dataBody
	case footerHeader
	case footerBody
	
	static var outline: [InspectorOutlineCell<ParserOutlineItem>] {
		return [.body(item: .parserListHeader),
						.body(item: .parserListBody),
						.body(item: .separator),
						.header(item: .experimentDetailsHeader,
										children: [.body(item: .experimentDetailsBody)]),
						.body(item: .separator),
						.header(item: .headerHeader,
										children: [.body(item: .headerBody)]),
						.body(item: .separator),
						.header(item: .dataHeader,
										children: [.body(item: .dataBody)]),
						.body(item: .separator),
						.header(item: .footerHeader,
										children: [.body(item: .footerBody)])]
	}
	
	var cellIdentifier: NSUserInterfaceItemIdentifier {
		switch self {
		case .separator:
			return .parserInspectorSeparatorCell
		case .parserListHeader:
			return .parserInspectorCategoryCell
		case .parserListBody:
			return .parserInspectorTableCell
		case .experimentDetailsHeader:
			return .parserInspectorCategoryCheckBoxCell
		case .experimentDetailsBody:
			return .parserInspectorExperimentDetailsCell
		case .headerHeader:
			return .parserInspectorCategoryCheckBoxCell
		case .headerBody:
			return .parserInspectorHeaderCell
		case .dataHeader:
			return .parserInspectorCategoryCheckBoxCell
		case .dataBody:
			return .parserInspectorDataCell
		case .footerHeader:
			return .parserInspectorCategoryCheckBoxCell
		case .footerBody:
			return .parserInspectorFooterCell
		}
	}
}
