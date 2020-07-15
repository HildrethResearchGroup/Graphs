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
	
	var showingCustomDetails: Bool = false
	
	override func prepareView(_ view: NSTableCellView, item: FileInspectorItem) {
		switch item {
		case .separator:
			// No customization for seperators
			break
		case .nameAndLocationHeader:
			view.textField?.stringValue = "Name & Location"
		case .templatesHeader:
			view.textField?.stringValue = "Templates"
		case .detailsHeader:
			let view = view as! InspectorCategoryOptionCell
			view.popUpButton.selectItem(at: showingCustomDetails ? 1: 0)
			view.textField?.stringValue = "Details"
		case .nameAndLocationBody:
			let view = view as! InspectorTwoTextFieldsCell
			guard let file = file else {
				view.firstTextField.stringValue = ""
				view.secondTextField.stringValue = ""
				break
			}
			view.firstTextField.stringValue = file.displayName
			view.secondTextField.stringValue = file.path?.path ?? ""
		case .templatesBody:
			// TODO: Select the correct templates
			#warning("Not implemented")
			break
		case .detailsBody:
			// TODO: Fill in the text view with the correct text
			#warning("Not implemented")
			break
		}
	}
}

extension FileInspectorViewController: InspectorSubViewController {
	
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
