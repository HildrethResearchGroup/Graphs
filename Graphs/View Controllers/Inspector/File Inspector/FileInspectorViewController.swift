//
//  FileInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class FileInspectorViewController: InspectorOutlineViewController<FileInspectorItem> {
	@IBOutlet weak var outlineView: NSOutlineView!
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
	}
	
	var file: File? {
		didSet {
			outlineView.reloadData()
		}
	}
	
	var showingCustomDetails: Bool = false {
		didSet {
			let lastRow = outlineView.numberOfRows - 1
			outlineView.reloadData(forRowIndexes: IndexSet(integer: lastRow),
														 columnIndexes: IndexSet(integer: 0))
		}
	}
	
	override func prepareView(_ view: NSTableCellView, item: FileInspectorItem) {
		switch item {
		case .separator:
			// No customization for seperators
			break
		case .nameAndLocationHeader:
			prepareNameAndLocationHeader(view)
		case .templatesHeader:
			prepareTemplatesHeader(view)
		case .detailsHeader:
			prepareDetailsHeader(view as! InspectorCategoryOptionCell)
		case .nameAndLocationBody:
			prepareNameAndLocationBody(view as! InspectorTwoTextFieldsCell)
		case .templatesBody:
			prepareTemplatesBody(view as! InspectorTwoPopUpButtonsCell)
		case .detailsBody:
			prepareDetailsBody(view as! InspectorTextViewCell)
		}
	}
}

// MARK: View Preparation
extension FileInspectorViewController {
	func prepareNameAndLocationHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Name & Location"
	}
	
	func prepareNameAndLocationBody(_ view: InspectorTwoTextFieldsCell) {
		guard let file = file else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
			return
		}
		view.firstTextField.stringValue = file.displayName
		view.secondTextField.stringValue = file.path?.path ?? ""
	}
	
	func prepareTemplatesHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Templates"
	}
	
	func prepareTemplatesBody(_ view: InspectorTwoPopUpButtonsCell) {
		prepareParser(popUpButton: view.firstPopUpButton)
		prepareGraphTemplates(popUpButton: view.secondPopUpButton)
		return
	}
	
	func prepareDetailsHeader(_ view: InspectorCategoryOptionCell) {
		view.popUpButton.selectItem(at: showingCustomDetails ? 1: 0)
		view.textField?.stringValue = "Details"
	}
	
	func prepareDetailsBody(_ view: InspectorTextViewCell) {
		view.textView.isEditable = showingCustomDetails
		view.textView.string = ""
		
		if showingCustomDetails {
			view.textView.string = file?.customDetails ?? ""
		} else {
			guard let file = file else { return }
			let parser = dataController?.parser(for: file)
			
			guard let parsedFile = parser?.parse(file: file) else { return }
			
			view.textView.string = parsedFile.experimentDetails
		}
	}
	
	func parserMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let file = file else { return [] }
		
		let items = dataController.parsers.enumerated().map { (index, parser) -> NSMenuItem in
			let item = NSMenuItem(title: parser.name,
														action: nil,
														keyEquivalent: "")
			item.tag = index
			return item
		}
		
		let fileTypeDefault = dataController.defaultParsers(forFileType: file.fileExtension ?? "").first
		
		let folderDefault = dataController.parser(for: file.parent!)
		
		let defaultItems = [NSMenuItem(title: "Default for File Type (\(fileTypeDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem(title: "Default for Directory (\(folderDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		defaultItems[0].isEnabled = fileTypeDefault != nil
		defaultItems[1].isEnabled = folderDefault != nil
		
		defaultItems[0].tag = -2
		defaultItems[1].tag = -1
		defaultItems[2].tag = Int.min
		
		return defaultItems + items
	}
	
	func prepareParser(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let file = file else { return }
		
		popUpButton.autoenablesItems = false
		popUpButton.menu?.items = parserMenuItems()
		
		if file.parser == nil {
			switch file.defaultParserMode {
			case .fileTypeDefault:
				popUpButton.selectItem(withTag: -2)
			case .folderDefault:
				popUpButton.selectItem(withTag: -1)
			}
			return
		}
		
		guard let parser = dataController.parser(for: file) else { return }
		guard let index = dataController.parsers.firstIndex(of: parser) else { return }
		
		popUpButton.selectItem(withTag: index)
	}
	
	func graphTemplateMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let file = file else { return [] }
		
		let items = dataController.graphTemplates.enumerated().map { (index, graphTemplate) -> NSMenuItem in
			let item = NSMenuItem(title: graphTemplate.name,
														action: nil,
														keyEquivalent: "")
			item.tag = index
			return item
		}
		
		let folderDefault = dataController.graphTemplate(for: file.parent!)
		
		let defaultItems = [NSMenuItem(title: "Default for Directory (\(folderDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		defaultItems[0].isEnabled = folderDefault != nil
		
		defaultItems[0].tag = -1
		defaultItems[1].tag = Int.min
		
		return defaultItems + items
	}
	
	func prepareGraphTemplates(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let file = file else { return }
		
		popUpButton.autoenablesItems = false
		popUpButton.menu?.items = graphTemplateMenuItems()
		
		if file.graphTemplate == nil {
			popUpButton.selectItem(withTag: -1)
			return
		}
		
		guard let parser = dataController.graphTemplate(for: file) else { return }
		guard let index = dataController.graphTemplates.firstIndex(of: parser) else { return }
		
		popUpButton.selectItem(withTag: index)
	}
}

// MARK: OutlineView Items
enum FileInspectorItem: InspectorOutlineCellItem {
	case separator
	case nameAndLocationHeader
	case nameAndLocationBody
	case templatesHeader
	case templatesBody
	case detailsHeader
	case detailsBody
	
	static var outline: [InspectorOutlineCell<Self>] {
		return [.header(item: .nameAndLocationHeader,
										children: [.body(item: .nameAndLocationBody)]),
						.body(item: .separator),
						.header(item: .templatesHeader,
										children: [.body(item: .templatesBody)]),
						.body(item: .separator),
						.header(item: .detailsHeader,
										children: [.body(item: .detailsBody)])]
	}
	
	var cellIdentifier: NSUserInterfaceItemIdentifier {
		switch self {
		case .separator:
			return .fileInspectorSeparatorCell
		case .nameAndLocationHeader, .templatesHeader:
			return .fileInspectorCategoryCell
		case .detailsHeader:
			return .fileInspectorCategoryOptionCell
		case .nameAndLocationBody:
			return .fileInspectorNameAndLocationCell
		case .templatesBody:
			return .fileInspectorTemplatesCell
		case .detailsBody:
			return .fileInspectorDetailsCell
		}
	}
	
	
}

// MARK: Helpers
extension FileInspectorViewController {
	var dataController: DataController? {
		return DataController.shared
	}
}

// MARK: Notifications
extension FileInspectorViewController {
	func registerObservers() {
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(reloadData(_:)),
																					 name: .fileRenamed,
																					 object: nil)
	}
	
	@objc func reloadData(_ notification: Notification) {
		outlineView.reloadData()
	}
}
