//
//  GraphInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the graph inspector.
class GraphInspectorViewController: NSViewController {
	/// The graph template selection table view.
	@IBOutlet weak var tableView: NSTableView!
	/// The text field which shows the source location on disk of the graph template.
	@IBOutlet weak var sourceTextField: NSTextField!
	/// The graph preview view.
	@IBOutlet weak var graphView: DPDrawingView!
	/// The error label to display if the graph preview cannot be shown.
	@IBOutlet weak var errorLabel: NSTextField!
	/// The DataGraph controller which displays the preview.
	var controller: DGController?
	/// A background queue for opening files in DataGraph.
	let queue = DispatchQueue(label: "openInDataGraph", qos: .background)
	/// Adds a new graph template by asking the user to import one.
	@IBAction func addGraphTemplate(_ sender: Any?)  {
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
	/// Removes the selected graph templates.
	@IBAction func removeGraphTemplate(_ button: NSButton) {
		removeSelectedGraphTemplates()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
		updateGraph()
	}
}

// MARK: Helpers
extension GraphInspectorViewController {
	/// The application's shared data controller.
	var dataController: DataController? {
		return DataController.shared
	}
	/// Removes the selected graph templates.
	func removeSelectedGraphTemplates() {
		guard let dataController = dataController else { return }
		let selection = tableView.selectedRowIndexes
		
		selection.map { dataController.graphTemplates[$0] }
			.forEach { dataController.remove(graphTemplate: $0) }
		
		tableView.removeRows(at: selection, withAnimation: .slideDown)
	}
	/// Updates the graph preview.
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
	/// Registers the controller to observe notifications.
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		// New graph templates will be added once the Core Data store is loaded, so we need to observe when this happens to reload the selection table view.
		notificationCenter.addObserver(self,
																	 selector: #selector(storeLoaded(_:)),
																	 name: .storeLoaded,
																	 object: nil)
		// When new graph templates are imported, the graph template table view needs to be reloaded
		notificationCenter.addObserver(self,
																	 selector: #selector(didImportGraphTemplate(_:)),
																	 name: .didImportGraphTemplate,
																	 object: nil)
	}
	/// Called when the Core Data store is loaded.
	@objc func storeLoaded(_ notification: Notification) {
		tableView.reloadData()
		updateGraph()
	}
	/// Called when a new graph template has been imported.
	@objc func didImportGraphTemplate(_ notifcation: Notification) {
		tableView.reloadData()
		updateGraph()
	}
}
