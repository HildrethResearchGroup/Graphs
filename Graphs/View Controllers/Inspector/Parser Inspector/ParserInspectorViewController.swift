//
//  ParserInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class ParserInspectorViewController: InspectorOutlineViewController<ParserOutlineItem>{
	@IBOutlet weak var outlineView: NSOutlineView!
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	var parser: Parser? {
		didSet {
			outlineView.reloadData()
		}
	}
	
	override func prepareView(_ view: NSTableCellView, item: ParserOutlineItem) {
		switch item {
		case .separator:
			// No customization needed
			break
		case .parserSelection:
			let view = view as! InspectorTableViewCell
//			view.tableView.delegate = self
//			view.tableView.dataSource = self
		case .experimentDetailsHeader:
			let view = view as! InspectorCategoryCheckBoxCell
			view.textField?.stringValue = "Experiment Details"
			guard let parser = parser else { return }
			view.checkBox.state = parser.hasExperimentDetails ? .on : .off
		case .experimentDetailsBody:
			let view = view as! InspectorTwoTextFieldsCell
			guard let parser = parser else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
				view.firstTextField.isEnabled = false
				view.secondTextField.isEnabled = false
				return
			}
			
			view.firstTextField.isEnabled = parser.hasExperimentDetails
			view.secondTextField.isEnabled = parser.hasExperimentDetails
			
			if parser.hasExperimentDetails {
				view.firstTextField.integerValue = parser.experimentDetailsStartOrGuess
				view.secondTextField.integerValue = parser.experimentDetailsEndOrGuess
			} else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
			}
		case .headerHeader:
			let view = view as! InspectorCategoryCheckBoxCell
			view.textField?.stringValue = "Header"
			guard let parser = parser else { return }
			view.checkBox.state = parser.hasHeader ? .on : .off
		case .headerBody:
			let view = view as! InspectorTwoTextFieldsOnePopUpButtonCell
			guard let parser = parser else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
				
				view.popUpButton.isEnabled = false
				view.firstTextField.isEnabled = false
				view.secondTextField.isEnabled = false
				return
			}
			
			view.popUpButton.isEnabled = parser.hasHeader
			view.firstTextField.isEnabled = parser.hasHeader
			view.secondTextField.isEnabled = parser.hasHeader
			
			if parser.hasHeader {
				let separatorMenu = NSMenu()
				Parser.Separator.allCases.forEach { separator in
					let item = NSMenuItem(title: separator.rawValue,
																action: nil,
																keyEquivalent: "")
					separatorMenu.addItem(item)
				}
				
				view.popUpButton.menu = separatorMenu
				view.popUpButton.selectItem(withTitle: parser.headerSeparator.rawValue)
				
				view.firstTextField.integerValue = parser.headerStartOrGuess
				view.secondTextField.integerValue = parser.headerEndOrGuess
			} else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
			}
		case .dataHeader:
			view.textField?.stringValue = "Data"
		case .dataBody:
			let view = view as! InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell
			guard let parser = parser else {
				view.textField?.stringValue = ""
				view.textField?.isEnabled = false
				view.popUpButton.isEnabled = false
				view.checkBox.isEnabled = false
				return
			}
			
			view.textField?.integerValue = parser.dataStartOrGuess
			let separatorMenu = NSMenu()
			Parser.Separator.allCases.forEach { separator in
				let item = NSMenuItem(title: separator.rawValue,
															action: nil,
															keyEquivalent: "")
				separatorMenu.addItem(item)
			}
			
			view.popUpButton.menu = separatorMenu
			view.popUpButton.selectItem(withTitle: parser.dataSeparator.rawValue)
			
			view.checkBox.state = parser.hasFooter ? .on : .off
		}
	}
}

// MARK: OutlineView Items
enum ParserOutlineItem: InspectorOutlineCellItem {
	case separator
	case parserSelection
	case experimentDetailsHeader
	case experimentDetailsBody
	case headerHeader
	case headerBody
	case dataHeader
	case dataBody
	
	static var outline: [InspectorOutlineCell<Self>] {
		return [.body(item: .parserSelection),
						.body(item: .separator),
						.header(item: .experimentDetailsHeader,
										children: [.body(item: .experimentDetailsBody)]),
						.body(item: .separator),
						.header(item: .headerHeader,
										children: [.body(item: .headerBody)]),
						.body(item: .separator),
						.header(item: .dataHeader,
										children: [.body(item: .dataBody)])]
	}
	
	var cellIdentifier: NSUserInterfaceItemIdentifier {
		switch self {
		case .separator:
			return .parserInspectorSeparatorCell
		case .parserSelection:
			return .parserInspectorSelectionCell
		case .experimentDetailsHeader:
			return .parserInspectorCategoryWithCheckBoxCell
		case .experimentDetailsBody:
			return .parserInspectorExperimentDetailsCell
		case .headerHeader:
			return .parserInspectorCategoryWithCheckBoxCell
		case .headerBody:
			return .parserInspectorHeaderCell
		case .dataHeader:
			return .parserInspectorCategoryCell
		case .dataBody:
			return .parserInspectorDataCell
		}
	}
}
