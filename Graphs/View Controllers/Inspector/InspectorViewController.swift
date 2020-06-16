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
		
	}
}

// MARK: Helpers
extension InspectorViewController {
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self,
																	 selector: #selector(filesSelectedDidChange(_:)),
																	 name: .filesSelectedDidChange,
																	 object: nil)
	}
	
	@objc func filesSelectedDidChange(_ notification: Notification) {
		func updateData(for file: File?) {
			invalidSelectionLabel.isHidden = file != nil
			tabView.isHidden = file == nil
			children.forEach { controller in
				(controller as? InspectorSubViewController)?.file = file
			}
		}
		
		guard let files = DataController.shared?.filesSelected else {
			invalidSelectionLabel.stringValue = "No File Selected"
			updateData(for: nil)
			return
		}
		
		switch files.count {
		case 0:
			invalidSelectionLabel.stringValue = "No File Selected"
			updateData(for: nil)
		case 1:
			updateData(for: files.first!)
		default:
			invalidSelectionLabel.stringValue = "Multiple Selection"
			updateData(for: nil)
		}
		
	}
}

protocol InspectorSubViewController: class {
	var file: File? { get set }
}
