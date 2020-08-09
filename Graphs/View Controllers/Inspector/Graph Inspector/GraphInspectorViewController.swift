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
	@IBOutlet weak var errorLabel: NSTextField!
	
	var controller: DGController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
		updateGraph()
	}
	
	@IBAction func addGraphTemplate(_ button: NSButton)  {
		guard let dataController = dataController else { return }
		let openPanel = NSOpenPanel()
		openPanel.canChooseDirectories = false
		openPanel.allowedFileTypes = ["dgraph"]
		openPanel.allowsMultipleSelection = true
		openPanel.runModal()
		
		let start = dataController.graphTemplates.count
		
		let newCount = openPanel.urls.reduce(0) { (count, url) -> Int in
			return dataController.importGraphTemplate(from: url) == nil ? count : count + 1
		}
		
		if newCount > 0 {
			let end = start + newCount
			tableView.insertRows(at: IndexSet(start..<end), withAnimation: .slideDown)
		}
	}
	
	@IBAction func removeGraphTemplate(_ button: NSButton) {
		guard let dataController = dataController else { return }
		let selection = tableView.selectedRowIndexes
		
		selection.map { dataController.graphTemplates[$0] }
			.forEach { dataController.remove(graphTemplate: $0) }
		
		tableView.removeRows(at: selection, withAnimation: .slideDown)
	}
	
}

// MARK: Helpers
extension GraphInspectorViewController {
	var dataController: DataController? {
		return DataController.shared
	}
	
	func updateGraph() {
		guard let dataController = dataController else {
			errorLabel.isHidden = false
			graphView.isHidden = true
			errorLabel.stringValue = "No Template Selected"
			sourceTextField.stringValue = ""
			return
		}
		
		let selection = tableView.selectedRowIndexes
		
		let graphTemplates = selection.map { dataController.graphTemplates[$0] }
		
		switch graphTemplates.count {
		case 0:
			errorLabel.isHidden = false
			errorLabel.stringValue = "No Template Selected"
			sourceTextField.stringValue = "No Template Selected"
		case 1:
			errorLabel.isHidden = true
			controller = graphTemplates.first!.controller
			controller?.setDrawingView(graphView)
			controller?.setDelegate(self)
			sourceTextField.stringValue = graphTemplates.first!.path?.path ?? ""
		default:
			errorLabel.isHidden = false
			errorLabel.stringValue = "Multiple Templates Selected"
			sourceTextField.stringValue = "Multiple Templates Selected"
		}
		
		graphView.isHidden = !errorLabel.isHidden
	}
}

// MARK: Notifications
extension GraphInspectorViewController {
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self,
																	 selector: #selector(storeLoaded(_:)),
																	 name: .storeLoaded,
																	 object: nil)
		notificationCenter.addObserver(self,
																	 selector: #selector(didImportGraphTemplate(_:)),
																	 name: .didImportGraphTemplate,
																	 object: nil)
	}
	
	@objc func storeLoaded(_ notification: Notification) {
		tableView.reloadData()
		updateGraph()
	}
	
	@objc func didImportGraphTemplate(_ notifcation: Notification) {
		tableView.reloadData()
		updateGraph()
	}
}
