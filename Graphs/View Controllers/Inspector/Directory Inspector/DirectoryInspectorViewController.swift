//
//  DirectoryInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class DirectoryInspectorViewController: InspectorOutlineViewController<DirectoryOutlineItem> {
	@IBOutlet weak var outlineView: NSOutlineView!
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	var directory: Directory? {
		didSet {
			outlineView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
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
	func prepareNameAndLocationHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Name & Location"
	}
	
	func prepareNameAndLocationBody(_ view: InspectorTwoTextFieldsCell) {
		guard let directory = directory else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
			return
		}
		view.firstTextField.stringValue = directory.displayName
		view.secondTextField.stringValue = directory.path?.path ?? ""
	}
	
	func prepareTemplatesHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Default Templates"
	}
	
	func prepareTemplatesBody(_ view: InspectorTwoPopUpButtonsCell) {
		prepareParser(popUpButton: view.firstPopUpButton)
		prepareGraphTemplate(popUpButton: view.secondPopUpButton)
	}
	
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
	case seperator
	case nameAndLocationHeader
	case nameAndLocationBody
	case templatesHeader
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
	var dataController: DataController? {
		return DataController.shared
	}
}

// MARK: Notificatoins
extension DirectoryInspectorViewController {
	func registerObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: .directoryRenamed, object: nil)
	}
	
	@objc func reloadData(_ notification: Notification) {
		if notification.object as? Directory == directory && directory != nil {
			outlineView.reloadData()
		}
	}
}
