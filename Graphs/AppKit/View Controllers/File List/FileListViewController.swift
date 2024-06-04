//
//  FileListViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 5/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the list of files.
class FileListViewController: NSViewController {
	/// The view which displays the graphed file contents.
	@IBOutlet weak var graphView: DPDrawingView!
	/// The error label to display if a file cannot be graphed.
	@IBOutlet weak var graphErrorLabel: NSTextField!
	/// The table view.
	@IBOutlet weak var tableView: NSTableView!
	/// The label in the bottom bar of the window. Displays the numebr of files in the directory selection as well as the currently selected files in the table view.
	@IBOutlet weak var itemsSelectedLabel: NSTextField!
	/// The progress indicator that is showed when background work is being performed.
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	/// The date formatter to format date cells in the table view.
	@IBOutlet var dateFormatter: DateFormatter!
	/// The byte count formatter to format file size cells in the table view.
	@IBOutlet var byteCountFormatter: ByteCountFormatter!
	/// `true` if the file list is currently updating, `false` otherwise.
	var fileListIsUpdating = false
	/// The data graph controller for displaying the graph.
	var controller: DGController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
		// Allows dragging files to the trash can to delete them
		tableView.setDraggingSourceOperationMask([.delete], forLocal: false)
	}
}

// MARK: Helper Functions
extension FileListViewController {
	/// The application's shared data controller.
	var dataController: DataController? {
		return DataController.shared
	}
	/// The application's shared core data context.
	var context: NSManagedObjectContext? {
		return dataController?.context
	}
	/// Updates the model with a list of the currently selected files as well as updates the bottom bar's label.
	func selectionDidChange() {
		updateSelectionLabel()
		guard let dataController = dataController else { return }
		// Update the selected files, which will send out a notificaiton to update the setter.
		let filesSelected = tableView.selectedRowIndexes
			.map { dataController.filesDisplayed[$0] }
		dataController.filesSelected = filesSelected
		updateGraph()
	}
	/// Updates the text on the bottom bar's label to indicate how many items are in the selected directories and how many are selected.
	func updateSelectionLabel() {
		let numberOfFiles = tableView.numberOfRows
		let numberOfSelectedFiles = tableView.numberOfSelectedRows
		let numberOfSelectedDirectories = dataController?.selectedDirectories.count ?? 0
		
		if numberOfSelectedDirectories == 0 {
			itemsSelectedLabel.stringValue = "0 directories selected"
			// Further processing is done down below, so just return now for this case
			return
		}
		
		// localize the word "directory" for plurality
		let directoriesText = numberOfSelectedDirectories == 1 ? "directory" : "directories"
		
		// localize the word "file" for plurality
		let filesText = numberOfFiles == 1 ? "file" : "files"
		
		if numberOfSelectedFiles == 0 {
			itemsSelectedLabel.stringValue = "\(numberOfFiles) \(filesText) in \(numberOfSelectedDirectories) \(directoriesText)"
		} else {
			
			itemsSelectedLabel.stringValue = "\(numberOfSelectedFiles) of \(numberOfFiles) files selected in \(numberOfSelectedDirectories) \(directoriesText)"
		}
	}
	/// Removes the selected files.
	func removeSelectedFiles() {
		let files = tableView.selectedRowIndexes.compactMap { index in
			dataController?.filesDisplayed[index]
		}
		remove(files: files)
	}
	/// Removes the given files.
	func remove(files: [File]) {
		guard let dataController = dataController else {
			print("[WARNING] directoryController was nil at FileListViewController.remove(files:rows:).")
			return
		}
		// Get the indicies of the rows that are being removed so we can animate their removal
		let rows = dataController.filesDisplayed.indicies(of: files)
		tableView.removeRows(at: rows, withAnimation: .slideDown)
		// Now actaully remove those files.
		files.forEach { file in
			dataController.remove(file: file)
		}
		selectionDidChange()
	}
	/// Updates the graph view.
	func updateGraph() {
		defer {
			graphErrorLabel.isHidden = !graphView.isHidden
		}
		graphView.isHidden = true
		guard let selectedFiles = dataController?.filesSelected else {
			graphErrorLabel.stringValue = "No File Selected"
			return
		}
		
		switch selectedFiles.count {
		case 0:
			graphErrorLabel.stringValue = "No File Selected"
		case 1:
			let file = selectedFiles.first!
			guard let dataController = dataController else {
				graphErrorLabel.stringValue = "Error Parsing File"
				break
			}
			
			let controller: DGController
			do {
				try controller = dataController.graphController(for: file)
			} catch let error as GraphControllerError {
				// Couldn't create the controller -- hide the graph and write an error
				let errorString: String
				switch error {
				case .noTemplate:
					errorString = "No Graph Template Selected"
				case .noParser:
					errorString = "No Parser Selected"
				case .noController:
					errorString = "Error Displaying Graph Template"
				case .failedToParse:
					errorString = "Error Parsing File"
				}
				graphErrorLabel.stringValue = errorString
				// Break to ensure that the graph remains hidden
				break
			} catch {
				print("[WARNING] Unknown error thrown from DataController.graphController(for:)")
				break
			}
			
			controller.setDrawingView(graphView)
			controller.setDelegate(self)
			
			self.controller = controller
			graphView.isHidden = false
		default:
			graphErrorLabel.stringValue = "Multiple Files Selected"
		}
	}
}

// MARK: Notifications
extension FileListViewController {
	/// Registers the view controller to observe notifications.
	func registerObservers() {
		let notificationCenter = NotificationCenter.default
		// Needs to be notified when the directory selection has changed in order to update the files to show
		notificationCenter.addObserver(self,
																	 selector: #selector(filesToShowDidChange(_:)),
																	 name: .filesDisplayedDidChange,
																	 object: nil)
		// Needs to be notified when the file list is being updated on another thread to show the progress indicator
		notificationCenter.addObserver(self,
																	 selector: #selector(fileListStartedWork(_:)),
																	 name: .fileListStartedWork,
																	 object: nil)
		notificationCenter.addObserver(self,
																	 selector: #selector(fileListFinishedWork(_:)),
																	 name: .fileListFinishedWork,
																	 object: nil)
		// Needs to be notified when the graph may have changed in order to regraph the file's contents.
		notificationCenter.addObserver(self,
																	 selector: #selector(graphMayHaveChanged(_:)),
																	 name: .graphMayHaveChanged,
																	 object: nil)
	}
	/// Called when the graph for the selected file may have changed.
	@objc func graphMayHaveChanged(_ notification: Notification) {
		updateGraph()
	}
	/// Called when a file was renamed.
	@objc func fileRenamed(_ notification: Notification) {
		guard let file = notification.object as? File else {
			print("[WARNING] fileRenamed notification did not have an object of type File.")
			return
		}
		guard let row = dataController?.filesDisplayed.firstIndex(of: file) else {
			return
		}
		
		let column = tableView.column(withIdentifier: .fileNameColumn)
		
		tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: column))
	}
	/// Called when the file list has started background work.
	@objc func fileListStartedWork(_ notification: Notification) {
		fileListIsUpdating = true
		tableView.reloadData()
		progressIndicator.startAnimation(self)
	}
	/// Called when the file list has finished background work.
	@objc func fileListFinishedWork(_ notification: Notification) {
		fileListIsUpdating = false
		tableView.reloadData()
		progressIndicator.stopAnimation(self)
	}
	/// Called when the files to be displayed has changed.
	@objc func filesToShowDidChange(_ notification: Notification) {
		let initiallySelectedFiles = dataController?.filesSelected
		/// Updates the currently selected files.
		func updateSelection() {
			defer {
				selectionDidChange()
			}
			
			guard let initial = initiallySelectedFiles else { return }
			
			guard let indicies = dataController?.filesDisplayed.indicies(of: initial) else { return }
			
			tableView.selectRowIndexes(indicies, byExtendingSelection: false)
		}
		
		if let userInfo = notification.userInfo as? [String: Any] {
			if let oldValue = userInfo[UserInfoKeys.oldValue] as? [File] {
				if let filesToShow = dataController?.filesDisplayed {
					let diff = filesToShow.difference(from: oldValue)
					
					let removalIndicies = diff.compactMap { change -> Int? in
						switch change {
						case .insert(offset: _, element: _, associatedWith: _):
							return nil
						case .remove(offset: let offset, element: _, associatedWith: _):
							return offset
						}
					}
					
					let insertionIndicies = diff.compactMap { change -> Int? in
						switch change {
						case .insert(offset: let offset, element: _, associatedWith: _):
							return offset
						case .remove(offset: _, element: _, associatedWith: _):
							return nil
						}
					}
					
					tableView.beginUpdates()
					tableView.removeRows(at: IndexSet(removalIndicies),
															 withAnimation: .slideDown)
					tableView.insertRows(at: IndexSet(insertionIndicies),
															 withAnimation: .slideDown)
					
					let collectionNameColumnIndex = tableView.column(withIdentifier: .fileCollectionNameColumn)
					// When moving files to a new directory the collection name may change, so reload that column
					tableView.reloadData(forRowIndexes: IndexSet(0..<filesToShow.count), columnIndexes: IndexSet(integer: collectionNameColumnIndex))
					
					tableView.endUpdates()
					updateSelection()
					return
				}
			}
		}
		
		// If the user dictionary didn't include the old collection in the userInfo dictionary then don't animate
		tableView.reloadData()
		// The selection may change so update the row selection label
		updateSelection()
	}
}
