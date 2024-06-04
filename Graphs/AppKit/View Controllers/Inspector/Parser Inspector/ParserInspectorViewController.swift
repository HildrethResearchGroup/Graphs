//
//  ParserInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the parser inspector.
class ParserInspectorViewController: InspectorOutlineViewController<ParserOutlineItem>{
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	/// The parser selection table view.
	weak var tableView: NSTableView?
	/// The parser that the view controller is showing information for.
	var parser: Parser? {
		didSet {
			reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
	}
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
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
	/// Prepares the parser selection table cell view.
	/// - Parameter view: The view to prepare.
	func prepareParserSelection(_ view: InspectorTableViewCell) {
		view.tableView.delegate = self
		view.tableView.dataSource = self
		tableView = view.tableView
		view.tableView.reloadData()
	}
	/// Prepares the experiment details header table cell view.
	/// - Parameter view: The view to prepare.
	func prepareExperimentDetailsHeader(_ view: InspectorCategoryCheckBoxCell) {
		view.textField?.stringValue = "Experiment Details"
		view.checkBox.isEnabled = parser != nil
		guard let parser = parser else { return }
		view.checkBox.state = parser.hasExperimentDetails ? .on : .off
	}
	/// Prepares the experiment details body table cell view.
	/// - Parameter view: The view to prepare.
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
	/// Prepares the header header table cell view.
	/// - Parameter view: The view to prepare.
	func prepareHeaderHeader(_ view: InspectorCategoryCheckBoxCell) {
		view.textField?.stringValue = "Header"
		view.checkBox.isEnabled = parser != nil
		guard let parser = parser else { return }
		view.checkBox.state = parser.hasHeader ? .on : .off
	}
	/// Prepares the header body table cell view.
	/// - Parameter view: The view to prepare.
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
	/// Prepares the data header table cell view.
	/// - Parameter view: The view to prepare.
	func prepareDataHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Data"
	}
	/// Prepares the data body table cell view.
	/// - Parameter view: The view to prepare.
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
	/// The application's shared data controller.
	var dataController: DataController? {
		return DataController.shared
	}
	/// Reloads the view's data.
	func reloadData() {
		let lastRow = outlineView.numberOfRows - 1
		outlineView.reloadData(forRowIndexes: IndexSet(integersIn: 1...lastRow),
													 columnIndexes: IndexSet(integer: 0))
	}
	/// Exports the currently selected parser in the table view.
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
	/// Deletes the selected parsers in the given table view.
	/// - Parameter tableView: The table view to delete the rows in.
	func deleteSelectedParsers(in tableView: NSTableView) {
		guard let dataController = dataController else { return }
		// Remove the parsers from the model.
		let rows = tableView.selectedRowIndexes
		let parsers = rows.map { dataController.parsers[$0] }
		parsers.forEach { dataController.remove(parser: $0) }
		// Update the table view
		tableView.removeRows(at: rows, withAnimation: .slideDown)
	}
	/// Adds a new parser in the given table view.
	/// - Parameter tableView: The table view to add the row to.
	func addParser(in tableView: NSTableView) {
		guard let dataController = dataController else { return }
		dataController.createParser()
		let lastRow = IndexSet(integer: dataController.parsers.count - 1)
		tableView.insertRows(at: lastRow, withAnimation: .slideDown)
	}
}

// MARK: Notifications
extension ParserInspectorViewController {
	/// Registers the view controller to recieve notificaitons.
	func registerObservers() {
		// When the store is loaded, the avialable parsers change, so we need to be notified when this happens so we can update the table view.
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(storeLoaded(_:)),
																					 name: .storeLoaded,
																					 object: nil)
		// When a parser is imported we need to be notified in order to update the table view.
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(didImportParser(_:)),
																					 name: .didImportParser,
																					 object: nil)
	}
	/// Called when the Core Data store has loaded.
	@objc func storeLoaded(_ notification: Notification) {
		outlineView.reloadData()
	}
	/// Called when a new parser was imported.
	@objc func didImportParser(_ notification: Notification) {
		outlineView.reloadData()
	}
}

// MARK: OutlineView Items
enum ParserOutlineItem: InspectorOutlineCellItem {
	/// A separator item.
	case separator
	/// The parser selection section.
	case parserSelection
	/// The header for the experiment details section.
	case experimentDetailsHeader
	/// The body for the experiment details.
	case experimentDetailsBody
	/// The header for the header section.
	case headerHeader
	/// The body for the header section.
	case headerBody
	/// The header for the data section.
	case dataHeader
	/// The body for the data section.
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
