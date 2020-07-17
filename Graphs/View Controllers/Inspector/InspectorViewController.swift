//
//  InspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 6/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController, InspectorButtonGroup {
	
	@IBOutlet weak var fileInspectorButton: InspectorButton!
	@IBOutlet weak var directoryInspectorButton: InspectorButton!
	@IBOutlet weak var parserInspectorButton: InspectorButton!
	@IBOutlet weak var graphInspectorButton: InspectorButton!
	@IBOutlet weak var dataInspectorButton: InspectorButton!
	
	@IBOutlet weak var tabView: NSTabView!
	@IBOutlet weak var invalidSelectionLabel: NSTextField!
	
	var inspectorButtons: [InspectorButton] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fileInspectorButton.group = self
		directoryInspectorButton.group = self
		parserInspectorButton.group = self
		graphInspectorButton.group = self
		dataInspectorButton.group = self
		
		select(inspectorButton: fileInspectorButton)
		registerObservers()
	}
	
	func didSelect(button: InspectorButton) {
		selectionDidChange(nil)
	}
}

// MARK: Helpers
extension InspectorViewController {
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self,
																	 selector: #selector(selectionDidChange(_:)),
																	 name: .filesSelectedDidChange,
																	 object: nil)
		notificationCenter.addObserver(self,
																	 selector: #selector(selectionDidChange(_:)),
																	 name: .directoriesSelectedDidChange,
																	 object: nil)
	}
	
	@objc func selectionDidChange(_ notification: Notification?) {
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
				setLabel(text: "No File Selected")
				controller.file = nil
			case (1, let file):
				setLabel(text: nil)
				controller.file = file
			default:
				setLabel(text: "Multiple Files Selected")
				controller.file = nil
			}
		case .directoryInspectorTab:
			guard let controller = tabController(ofType: DirectoryInspectorViewController.self) else {
				break
			}
			
			switch (directories?.count, directories?.first) {
				case (nil, _), (0, _):
					setLabel(text: "No Directory Selected")
					controller.directory = nil
				case (1, let directory):
					setLabel(text: nil)
					controller.directory = directory
				default:
					setLabel(text: "Multiple Directories Selected")
					controller.directory = nil
			}
		case .parserInspectorTab:
			setLabel(text: nil)
		case .graphInspectorTab:
			setLabel(text: nil)
		case .dataInspectorTab:
			guard let controller = tabController(ofType: DataInspectorViewController.self) else {
				break
			}
			
			switch (files?.count, files?.first) {
			case (nil, _), (0, _):
				setLabel(text: "No File Selected")
				controller.file = nil
			case (1, let file):
				setLabel(text: nil)
				controller.file = file
			default:
				setLabel(text: "Multiple Files Selected")
				controller.file = nil
			}
		default:
			break
		}
	}
}

protocol InspectorSubViewController: class {
	var file: File? { get set }
}
