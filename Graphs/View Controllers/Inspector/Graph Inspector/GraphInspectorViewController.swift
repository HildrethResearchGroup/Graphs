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
		
		if let controller = DGController(fileInBundle: "Basic Script") {
			self.controller = controller
			controller.setDrawingView(graphView)
			controller.setDelegate(self)
			
			let xEntries = ["0", "2", "3", "5", "7", "10"]
			let yEntries = ["0", "3", "2", "1", "3", "5"]
			controller.dataColumn(at: 1).setDataFrom(xEntries)
			controller.dataColumn(at: 2).setDataFrom(yEntries)
			
			let xAxis = controller.xAxisNumber(0)
			xAxis?.setCropRange(DGRange(minV: 1.0, maxV: 2.0))
		} else {
			print("[WARNING] Failed to init controller")
		}
	}
	
	@IBAction func addGraphTemplate(_ button: NSButton)  {
		
	}
	
	@IBAction func removeGraphTemplate(_ button: NSButton) {
		
	}
	
}
