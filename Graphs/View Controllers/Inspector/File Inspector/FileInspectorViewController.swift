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
	
	var file: File?
	
	var showingCustomDetails: Bool = false
	
	override func prepareView(_ view: NSTableCellView, item: FileInspectorItem) {
		switch item {
			
		case .separator, .nameAndLocationHeader, .templatesHeader:
			// No customization for basic category cells and seperators
			return
		case .detailsHeader:
			let view = view as! FileInspectorCategoryOptionCell
			view.popUpButton.selectItem(at: showingCustomDetails ? 1: 0)
		case .nameAndLocationBody:
			let view = view as! FileInspectorNameAndLocationCell
			guard let file = file else {
				view.pathTextField.stringValue = ""
				return
			}
			view.nameTextField.stringValue = file.displayName
			view.pathTextField.stringValue = file.path?.absoluteString ?? ""
		case .templatesBody:
			// TODO: Select the correct templates
			return
		case .detailsBody:
			// TODO: Fill in the text view with the correct text
			return
		}
	}
}

enum FileInspectorItem: InspectorOutlineCellItem {
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
	
	case separator
	case nameAndLocationHeader
	case nameAndLocationBody
	case templatesHeader
	case templatesBody
	case detailsHeader
	case detailsBody
	
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
