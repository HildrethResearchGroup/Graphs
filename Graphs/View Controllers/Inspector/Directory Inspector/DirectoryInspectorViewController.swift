//
//  DirectoryInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the directory inspector.
class DirectoryInspectorViewController: InspectorOutlineViewController<DirectoryOutlineItem> {
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	/// The directory that the controller is displaying.
	var directory: Directory? {
		didSet {
			outlineView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
	}
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	override func prepareView(_ view: NSTableCellView, item: DirectoryOutlineItem) {
		switch item {
		case .seperator:
			// To customization needed for separators
			break
		case .nameAndLocationHeader:
			prepareNameAndLocationHeader(view)
		case .nameAndLocationBody:
			prepareNameAndLocationBody(view as! InspectorTwoTextFieldsCell)
		case .templatesHeader:
			prepareTemplatesHeader(view)
		case .templatesBody:
			prepareTemplatesBody(view as! InspectorTwoPopUpButtonsCell)
		}
	}
}

// MARK: View Separation
extension DirectoryInspectorViewController {
	/// Prepares the name and location header table cell view.
	/// - Parameter view: The view to be prepared.
	func prepareNameAndLocationHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Name & Location"
	}
	/// Prepares the name and location body table cell view.
	/// - Parameter view: The view to be prepared.
	func prepareNameAndLocationBody(_ view: InspectorTwoTextFieldsCell) {
		guard let directory = directory else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
			return
		}
		view.firstTextField.stringValue = directory.displayName
		view.secondTextField.stringValue = directory.path?.path ?? ""
	}
	/// Prepares the templates header table cell view.
	/// - Parameter view: The view to be prepared.
	func prepareTemplatesHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Default Templates"
	}
	/// Prepares the templates body table cell view.
	/// - Parameter view: The view to be prepared.
	func prepareTemplatesBody(_ view: InspectorTwoPopUpButtonsCell) {
		prepareParser(popUpButton: view.firstPopUpButton)
		prepareGraphTemplate(popUpButton: view.secondPopUpButton)
	}
	/// Retunrs the menu items to be displayed in the parser pop up button.
	/// - Returns: The menu items to be displayed in the parser pop up button.
	func parserMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let directory = directory else { return [] }
		
		let items = dataController.parsers.enumerated().map { (index, parser) -> NSMenuItem in
			let item = NSMenuItem(title: parser.name,
														action: nil,
														keyEquivalent: "")
			item.tag = index
			return item
		}
		
		let parentDefault = dataController.parser(for: directory.parent!)
		
		let defaultItems = [NSMenuItem(title: "Default for Directory (\(parentDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		defaultItems[0].tag = -1
		defaultItems[1].tag = Int.min
		return defaultItems + items
	}
	/// Prepares the parser pop up button.
	/// - Parameter popUpButton: The pop up button to prepare.
	func prepareParser(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let directory = directory else { return }
		
		popUpButton.autoenablesItems = false
		popUpButton.menu?.items = parserMenuItems()
		
		guard directory.parser != nil else {
			popUpButton.selectItem(withTag: -1)
			return
		}
		
		guard let parser = dataController.parser(for: directory) else { return }
		guard let index = dataController.parsers.firstIndex(of: parser) else { return }
		
		popUpButton.selectItem(withTag: index)
	}
	/// Returns the menu items to be displayed in the graph templates pop up button.
	/// - Returns: The menu items to be displayed in the graph templates pop up button.
	func graphTemplateMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let directory = directory else { return [] }
		
		let items = dataController.graphTemplates.enumerated().map { (index, graphTemplate) -> NSMenuItem in
			let item = NSMenuItem(title: graphTemplate.name,
														action: nil,
														keyEquivalent: "")
			item.tag = index
			return item
		}
		
		let parentDefault = dataController.graphTemplate(for: directory.parent!)
		
		let defaultItems = [NSMenuItem(title: "Default from Parent (\(parentDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		defaultItems[0].tag = -1
		defaultItems[1].tag = Int.min
		return defaultItems + items
	}
	/// Prepares the graph template pop up button
	/// - Parameter popUpButton: The pop up button to prepare.
	func prepareGraphTemplate(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let directory = directory else { return }
		
		popUpButton.autoenablesItems = false
		popUpButton.menu?.items = graphTemplateMenuItems()
		
		guard directory.graphTemplate != nil else {
			popUpButton.selectItem(withTag: -1)
			return
		}
		
		guard let parser = dataController.graphTemplate(for: directory) else { return }
		guard let index = dataController.graphTemplates.firstIndex(of: parser) else { return }
		
		popUpButton.selectItem(withTag: index)
	}
}

// MARK: OutlineView Items
enum DirectoryOutlineItem: InspectorOutlineCellItem {
	/// A separator item.
	case seperator
	/// The header for the name and location section.
	case nameAndLocationHeader
	/// The body fot the name and location section.
	case nameAndLocationBody
	/// The header for the templates section.
	case templatesHeader
	/// The body for the templates section.
	case templatesBody
	
	static var outline: [InspectorOutlineCell<DirectoryOutlineItem>] {
		return [.header(item: .nameAndLocationHeader,
										children: [.body(item: .nameAndLocationBody)]),
						.body(item: .seperator),
						.header(item: .templatesHeader,
										children: [.body(item: .templatesBody)])]
	}
	
	var cellIdentifier: NSUserInterfaceItemIdentifier {
		switch self {
		case .seperator:
			return .directoryInspectorSeparatorCell
		case .nameAndLocationHeader:
			return .directoryInspectorCategoryCell
		case .nameAndLocationBody:
			return .directoryInspectorNameAndLocationCell
		case .templatesHeader:
			return .directoryInspectorCategoryCell
		case .templatesBody:
			return .directoryInspectorTemplatesCell
		}
	}
}

// MARK: Helpers
extension DirectoryInspectorViewController {
	/// The application's shared data controller.
	var dataController: DataController? {
		return DataController.shared
	}
}

// MARK: Notificatoins
extension DirectoryInspectorViewController {
	/// Registers the view controller for notifications
	func registerObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: .directoryRenamed, object: nil)
	}
	/// Reloads the view's data.
	@objc func reloadData(_ notification: Notification) {
		if notification.object as? Directory == directory && directory != nil {
			outlineView.reloadData()
		}
	}
}
