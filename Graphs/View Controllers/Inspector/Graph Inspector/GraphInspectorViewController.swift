//
//  GraphInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class GraphInspectorViewController: NSViewController {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var sourceTextField: NSTextField!
	@IBOutlet weak var graphView: DPDrawingView!
	
	var controller: DGController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let controller = DGController(fileInBundle: "Sample Graph") {
			self.controller = controller
			controller.setDrawingView(graphView)
			controller.setDelegate(self)
			
		} else {
			print("[WARNING] Failed to init controller")
		}
	}
	
	@IBAction func addGraphTemplate(_ button: NSButton)  {
		
	}
	
	@IBAction func removeGraphTemplate(_ button: NSButton) {
		
	}
	
}
