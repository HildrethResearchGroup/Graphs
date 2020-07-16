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
	
	var tf: NSTextField?
	
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
			return
		case .nameAndLocationHeader:
			view.textField?.stringValue = "Name & Location"
		case .nameAndLocationBody:
			let view = view as! InspectorTwoTextFieldsCell
			//view.firstTextField.delegate = self
			tf = view.firstTextField
			guard let directory = directory else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
				return
			}
			view.firstTextField.stringValue = directory.displayName
			view.secondTextField.stringValue = directory.path?.path ?? ""
		case .templatesHeader:
			view.textField?.stringValue = "Default Templates"
		case .templatesBody:
			guard let dataController = dataController else { break }
			guard let directory = directory else { break }
			let view = view as! InspectorTwoPopUpButtonsCell
			
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
			
			view.firstPopUpButton.autoenablesItems = false
			view.firstPopUpButton.menu?.items = defaultItems + items
			
			guard directory.parser != nil else {
				view.firstPopUpButton.selectItem(withTag: -1)
				break
			}
			
			guard let parser = dataController.parser(for: directory) else { break }
			
			guard let index = dataController.parsers.firstIndex(of: parser) else { break }
			
			view.firstPopUpButton.selectItem(withTag: index)
			return
		}
	}
}

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
