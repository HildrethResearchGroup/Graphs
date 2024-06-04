//
//  InspectorController.swift
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
	
	var inspectorButtons: [InspectorButton] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fileInspectorButton.group = self
		directoryInspectorButton.group = self
		parserInspectorButton.group = self
		graphInspectorButton.group = self
		dataInspectorButton.group = self
		
		select(inspectorButton: fileInspectorButton)
	}
	
	func didSelect(button: InspectorButton) {
		
	}
}
