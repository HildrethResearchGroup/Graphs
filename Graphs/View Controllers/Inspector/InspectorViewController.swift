//
//  InspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller that manages the tabs of the inspector.
class InspectorViewController: NSViewController, InspectorButtonGroup {
	/// The file inspector tab button.
	@IBOutlet weak var fileInspectorButton: InspectorButton!
	/// The directory inspector tab button.
	@IBOutlet weak var directoryInspectorButton: InspectorButton!
	/// The parser inspector tab button.
	@IBOutlet weak var parserInspectorButton: InspectorButton!
	/// The graph inspector tab button.
	@IBOutlet weak var graphInspectorButton: InspectorButton!
	/// The data inspector tab button.
	@IBOutlet weak var dataInspectorButton: InspectorButton!
	/// The tab view which contains the view controllers for each of the tabs.
	@IBOutlet weak var tabView: NSTabView!
	/// The label which is displayed if there is an invalid selection for the given inspector tab.
	@IBOutlet weak var invalidSelectionLabel: NSTextField!
	
	var inspectorButtons: [InspectorButton] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// The view controller conforms to InspectorButtonGroup, so it manages the tab buttons -- make sure that the group is set to this view controller for each of the inspector tab buttons.
		fileInspectorButton.group = self
		directoryInspectorButton.group = self
		parserInspectorButton.group = self
		graphInspectorButton.group = self
		dataInspectorButton.group = self
		// Start with the file inspector selected.
		select(inspectorButton: fileInspectorButton)
		registerObservers()
	}
	
	func didSelect(button: InspectorButton) {
		selectionDidChange(nil)
	}
}

// MARK: Helpers
extension InspectorViewController {
	/// Register observers for relevent notifications.
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		// When the files selected changes, the file inspector tab will need to be updated
		notificationCenter.addObserver(self,
																	 selector: #selector(selectionDidChange(_:)),
																	 name: .filesSelectedDidChange,
																	 object: nil)
		// When the directories selected changes, the directory inspector tab will need to be updated
		notificationCenter.addObserver(self,
																	 selector: #selector(selectionDidChange(_:)),
																	 name: .directoriesSelectedDidChange,
																	 object: nil)
	}
	/// Selects the proper tab view to display and updates the tab's view controller.
	@objc func selectionDidChange(_ notification: Notification?) {
		/// Sets the error label's text, or hides the label if `text` is `nil`.
		/// - Parameter text: The error text to display, or `nil` if the label should be hidden.
		func setLabel(text: String?) {
			tabView.isHidden = text != nil
			invalidSelectionLabel.stringValue = text ?? ""
		}
		
		let files = DataController.shared?.filesSelected
		let directories = DataController.shared?.selectedDirectories
		
		guard let tabIdentifier = tabView.selectedTabViewItem?.identifier as? NSUserInterfaceItemIdentifier else {
			setLabel(text: "No Tab Selected")
			return
		}
		
		/// Returns the first child view controller in the tab view that is of the given type.
		/// - Parameter type: The type of the view controller.
		/// - Returns: The first child view controller in the tab view that is of the given type.
		func tabController<T: NSViewController>(ofType type: T.Type) -> T? {
			return children.first { $0 is T } as? T
		}
		
		switch tabIdentifier {
		case .fileInspectorTab:
			guard let controller = tabController(ofType: FileInspectorViewController.self) else {
				break
			}
				
			switch (files?.count, files?.first) {
			case (nil, _), (0, _):
				// If no files are selected there is no information to show.
				setLabel(text: "No File Selected")
				controller.file = nil
			case (1, let file):
				setLabel(text: nil)
				controller.file = file
			default:
				// If there are multiple files, don't show any information
				// TODO: Support bulk editing files for certian fields. For example, if multiple files are selected, the user should be able to set their default parser and graph template all at once. The name field should probably not be editable though
				setLabel(text: "Multiple Files Selected")
				controller.file = nil
			}
		case .directoryInspectorTab:
			guard let controller = tabController(ofType: DirectoryInspectorViewController.self) else {
				break
			}
			
			switch (directories?.count, directories?.first) {
				case (nil, _), (0, _):
					// If no directories are selected there is no information to show
					setLabel(text: "No Directory Selected")
					controller.directory = nil
				case (1, let directory):
					setLabel(text: nil)
					controller.directory = directory
				default:
					// If there are directories files, don't show any information
					// TODO: Support bulk editing directories for certian fields. For example, if multiple directories are selected, the user should be able to set their default parser and graph template all at once. The name field should probably not be editable though
					setLabel(text: "Multiple Directories Selected")
					controller.directory = nil
			}
		case .parserInspectorTab:
			// Regardless of the files and directories selected, the parser inspector can be shown.
			setLabel(text: nil)
		case .graphInspectorTab:
			// Regardless of the files and directories selected, the parser inspector can be shown.
			setLabel(text: nil)
		case .dataInspectorTab:
			guard let controller = tabController(ofType: DataInspectorViewController.self) else {
				break
			}
			
			switch (files?.count, files?.first) {
			case (nil, _), (0, _):
				// If no files are selected there is no information to show
				setLabel(text: "No File Selected")
				controller.file = nil
			case (1, let file):
				setLabel(text: nil)
				controller.file = file
			default:
				// If there are multiple files, don't show any information
				setLabel(text: "Multiple Files Selected")
				controller.file = nil
			}
		default:
			break
		}
	}
}
