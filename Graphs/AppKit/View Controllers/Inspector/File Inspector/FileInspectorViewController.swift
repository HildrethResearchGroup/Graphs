//
//  FileInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the file inspector.
class FileInspectorViewController: InspectorOutlineViewController<FileInspectorItem> {
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	/// The file that the inspector is showing information for.
	var file: File? {
		didSet {
			outlineView.reloadData()
		}
	}
	/// `true` if the inspector is showing custom details in the text view, `false` if the inspector is showing details from the file's data in the text view.
	var showingCustomDetails: Bool = false {
		didSet {
			let lastRow = outlineView.numberOfRows - 1
			// When the text view's data source is changed, refresh it. The text view is the last item in the outline view, so only reload the last cell
			outlineView.reloadData(forRowIndexes: IndexSet(integer: lastRow),
														 columnIndexes: IndexSet(integer: 0))
		}
	}
	
	override var primaryOutlineView: NSOutlineView? {
		return outlineView
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
	/// Set's the cell's text to the category name.
	/// - Parameter view: The table cell view to prepare.
	func prepareNameAndLocationHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Name & Location"
	}
	/// Set's the cell's file name and location text fields' text to the file's current name and location.
	/// - Parameter view: The table cell view to prepare.
	func prepareNameAndLocationBody(_ view: InspectorTwoTextFieldsCell) {
		guard let file = file else {
			view.firstTextField.stringValue = ""
			view.secondTextField.stringValue = ""
			return
		}
		view.firstTextField.stringValue = file.displayName
		view.secondTextField.stringValue = file.path?.path ?? ""
	}
	/// Set's the cell's text to the category name.
	/// - Parameter view: The table cell view to prepare.
	func prepareTemplatesHeader(_ view: NSTableCellView) {
		view.textField?.stringValue = "Templates"
	}
	/// Set's the cell's pop up buttons' items, and selects the items for the file's current parser and template.
	/// - Parameter view: The table cell view to prepare.
	func prepareTemplatesBody(_ view: InspectorTwoPopUpButtonsCell) {
		prepareParser(popUpButton: view.firstPopUpButton)
		prepareGraphTemplates(popUpButton: view.secondPopUpButton)
		return
	}
	/// Set's the cell's text to the category name, and assigns the correct option to the pop up button.
	/// - Parameter view: The table cell view to prepare.
	func prepareDetailsHeader(_ view: InspectorCategoryOptionCell) {
		// The pop up button's first item is "From File", the second item is "Custom"
		view.popUpButton.selectItem(at: showingCustomDetails ? 1: 0)
		view.textField?.stringValue = "Details"
	}
	/// Set's the cell's text to the file's current details (either from file or custom), and enables or disables editing depending on the source of the details.
	/// - Parameter view: The table cell view to prepare.
	func prepareDetailsBody(_ view: InspectorTextViewCell) {
		// Custom details can be editied by the user, but experiment details are derived from the file's contents, so prevent editing
		view.textView.isEditable = showingCustomDetails
		// Set the string to empty in case this function returns early
		view.textView.string = ""
		
		if showingCustomDetails {
			view.textView.string = file?.customDetails ?? ""
		} else {
			// The file has to be parsed in order to determine its experiment details
			guard let file = file else { return }
			let parser = dataController?.parser(for: file)
			
			guard let parsedFile = parser?.parse(file: file) else { return }
			
			view.textView.string = parsedFile.experimentDetails
		}
	}
	/// Returns the menu items that should be shown in the parser pop up menu.
	func parserMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let file = file else { return [] }
		
		// Make a menu item for each parser
		let items = dataController.parsers.enumerated().map { (index, parser) -> NSMenuItem in
			let item = NSMenuItem(title: parser.name,
														action: nil,
														keyEquivalent: "")
			// Use the index as the tab to easily convert tag -> parser
			item.tag = index
			return item
		}
		
		// Determine the name for the default parser for both types so that they can be shown in parenthesis next to the options "default for file type" and "default for directory"
		let fileTypeDefault = dataController.defaultParsers(forFileType: file.fileExtension ?? "").first
		// The file's parent is passed in (which must be non-nil because all files belong to a parent directory) so that the method cannot fallback on using the file's default for its file type
		let folderDefault = dataController.parser(for: file.parent!)
		
		// Make menu items for choosing the default parser for the file's file type or the file's parent directory's default parser
		let defaultItems = [NSMenuItem(title: "Default for File Type (\(fileTypeDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem(title: "Default for Directory (\(folderDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		// If there is not a default parser for the file's file type or parent directory, then disable that menu item
		defaultItems[0].isEnabled = fileTypeDefault != nil
		defaultItems[1].isEnabled = folderDefault != nil
		// Positive integers are used for explicitly set parsers, so use negative integers for the default options
		defaultItems[0].tag = -2
		defaultItems[1].tag = -1
		// The third item is the separator, set its tag so its no longer 0. Int.min is used so that if additional default options are added in the future (with subsequnet negative numbers) the separator's tag doesn't need to be changed
		defaultItems[2].tag = Int.min
		
		// Display the default options first
		return defaultItems + items
	}
	/// Prepares the given pop up button with the correct parser menu.
	func prepareParser(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let file = file else { return }
		
		// The function parserMenuItems() manually enables menu items
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
		
		// The file's parser is explicitly defined (file.parser == nil is checked above), so select the menu item for that parser
		guard let parser = dataController.parser(for: file) else { return }
		guard let index = dataController.parsers.firstIndex(of: parser) else { return }

		popUpButton.selectItem(withTag: index)
	}
	/// Returns the menu items that should be shown in the graph templates pop up menu.
	func graphTemplateMenuItems() -> [NSMenuItem] {
		guard let dataController = dataController else { return [] }
		guard let file = file else { return [] }
		
		// Make a menu item for each graph template
		let items = dataController.graphTemplates.enumerated().map { (index, graphTemplate) -> NSMenuItem in
			let item = NSMenuItem(title: graphTemplate.name,
														action: nil,
														keyEquivalent: "")
			// Use the index as the tab to easily convert tag -> parser
			item.tag = index
			return item
		}
		
		// Determine the name for the default graph template so that it can be shown in parenthesis next to the options "default for directory"
		let folderDefault = dataController.graphTemplate(for: file.parent!)
		
		// Make menu items for choosing the default graph template for the file's parent directory's default graph template
		let defaultItems = [NSMenuItem(title: "Default for Directory (\(folderDefault?.name ?? "None"))",
																	 action: nil,
																	 keyEquivalent: ""),
												NSMenuItem.separator()]
		
		// If there is not a default parser for the file's parent directory, then disable that menu item
		defaultItems[0].isEnabled = folderDefault != nil
		// Positive integers are used for explicitly set parsers, so use negative integers for the default options
		defaultItems[0].tag = -1
		// The third item is the separator, set its tag so its no longer 0. Int.min is used so that if additional default options are added in the future (with subsequnet negative numbers) the separator's tag doesn't need to be changed
		defaultItems[1].tag = Int.min
		
		// Display the default options first
		return defaultItems + items
	}
	/// Prepares the given pop up button with the correct graph template menu.
	func prepareGraphTemplates(popUpButton: NSPopUpButton) {
		guard let dataController = dataController else { return }
		guard let file = file else { return }
		
		// The function graphTemplateMenuItems() manually enables menu items
		popUpButton.autoenablesItems = false
		popUpButton.menu?.items = graphTemplateMenuItems()
		
		if file.graphTemplate == nil {
			popUpButton.selectItem(withTag: -1)
			return
		}
		
		// The file's graph template is explicitly defined (file.graphTemplate == nil is checked above), so select the menu item for that parser
		guard let graphTemplate = dataController.graphTemplate(for: file) else { return }
		guard let index = dataController.graphTemplates.firstIndex(of: graphTemplate) else { return }
		
		popUpButton.selectItem(withTag: index)
	}
}

// MARK: OutlineView Items
/// An item in the file inspector outline view.
enum FileInspectorItem: InspectorOutlineCellItem {
	/// A vertical line separator.
	case separator
	/// The header for the name and location section.
	case nameAndLocationHeader
	/// The name and location section contents.
	case nameAndLocationBody
	/// The header for the header section.
	case templatesHeader
	/// The templates section contents.
	case templatesBody
	/// The header for the details section.
	case detailsHeader
	/// The details section contents.
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
	/// The data controller that manages the model.
	var dataController: DataController? {
		return DataController.shared
	}
}

// MARK: Notifications
extension FileInspectorViewController {
	/// Register observers for relevent notifications.
	func registerObservers() {
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(reloadData(_:)),
																					 name: .fileRenamed,
																					 object: nil)
	}
	/// Reloads the inspector's contents.
	@objc func reloadData(_ notification: Notification) {
		outlineView.reloadData()
	}
}
