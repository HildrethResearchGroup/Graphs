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
	
	weak var tableView: NSTableView?
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	var parser: Parser? {
		didSet {
			reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
	}
	
	override func prepareView(_ view: NSTableCellView, item: ParserOutlineItem) {
		switch item {
		case .separator:
			// No customization needed
			break
		case .parserSelection:
			prepareParserSelection(view as! InspectorTableViewCell)
		case .experimentDetailsHeader:
			prepareExperimentDetailsHeader(view as! InspectorCategoryCheckBoxCell)
		case .experimentDetailsBody:
			prepareExperimentDetailsBody(view as! InspectorTwoTextFieldsCell)
		case .headerHeader:
			prepareHeaderHeader(view as! InspectorCategoryCheckBoxCell)
		case .headerBody:
			prepareHeaderBody(view as! InspectorTwoTextFieldsOnePopUpButtonCell)
		case .dataHeader:
			prepareDataHeader(view)
		case .dataBody:
			prepareDataBody(view as! InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
		}
	}
}

// MARK: View Preparation
extension ParserInspectorViewController {
	func prepareParserSelection(_ view: InspectorTableViewCell) {
		view.tableView.delegate = self
		view.tableView.dataSource = self
		tableView = view.tableView
		view.tableView.reloadData()
	}
	
	func prepareExperimentDetailsHeader(_ view: InspectorCategoryCheckBoxCell) {
		view.textField?.stringValue = "Experiment Details"
		view.checkBox.isEnabled = parser != nil
		guard let parser = parser else { return }
		view.checkBox.state = parser.hasExperimentDetails ? .on : .off
	}
	
	func prepareExperimentDetailsBody(_ view: InspectorTwoTextFieldsCell) {
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
			
			view.firstTextField.setValid(parser.experimentDetailsStartIsValid)
			view.secondTextField.setValid(parser.experimentDetailsEndIsValid)
			
			dataController?.setNeedsSaved()
		} else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
		}
	}
	
	func prepareHeaderHeader(_ view: InspectorCategoryCheckBoxCell) {
		view.textField?.stringValue = "Header"
		view.checkBox.isEnabled = parser != nil
		guard let parser = parser else { return }
		view.checkBox.state = parser.hasHeader ? .on : .off
	}
	
	func prepareHeaderBody(_ view: InspectorTwoTextFieldsOnePopUpButtonCell) {
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
			
			view.firstTextField.setValid(parser.headerStartIsValid)
			view.secondTextField.setValid(parser.headerEndIsValid)
			
			dataController?.setNeedsSaved()
		} else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
		}
	}
	
	func prepareDataHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Data"
	}
	
	func prepareDataBody(_ view: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell) {
		guard let parser = parser else {
			view.textField?.stringValue = ""
			view.textField?.isEnabled = false
			view.popUpButton.isEnabled = false
			view.checkBox.isEnabled = false
			return
		}
		
		view.textField?.isEnabled = true
		view.popUpButton.isEnabled = true
		view.checkBox.isEnabled = true
		
		view.textField?.integerValue = parser.dataStartOrGuess
		view.textField?.setValid(parser.dataStartIsValid)
		
		dataController?.setNeedsSaved()
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


// MARK: Helpers
extension ParserInspectorViewController {
	var dataController: DataController? {
		return DataController.shared
	}
	
	func reloadData() {
		let lastRow = outlineView.numberOfRows - 1
		outlineView.reloadData(forRowIndexes: IndexSet(integersIn: 1...lastRow),
													 columnIndexes: IndexSet(integer: 0))
	}
	
	func exportSelectedParser() {
		guard let dataController = dataController else { return }
		guard let tableView = tableView else { return }
		guard tableView.selectedRowIndexes.count == 1 else { return }
		let parser = dataController.parsers[tableView.selectedRowIndexes.first!]
		
		let savePanel = NSSavePanel()
		savePanel.allowedFileTypes = ["gparser"]
		savePanel.canCreateDirectories = true
		savePanel.nameFieldStringValue = parser.name
		guard let window = view.window else { return }
		savePanel.beginSheetModal(for: window) { (response) in
			if response == .OK, let url = savePanel.url {
				parser.export(to: url)
			}
		}
	}
}

// MARK: Notifications
extension ParserInspectorViewController {
	func registerObservers() {
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(storeLoaded(_:)),
																					 name: .storeLoaded,
																					 object: nil)
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(didImportParser(_:)),
																					 name: .didImportParser,
																					 object: nil)
	}
	
	@objc func storeLoaded(_ notification: Notification) {
		outlineView.reloadData()
	}
	
	@objc func didImportParser(_ notification: Notification) {
		outlineView.reloadData()
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
