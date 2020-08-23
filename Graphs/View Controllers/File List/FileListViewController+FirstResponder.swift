//
//  FileListViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 6/7/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension FileListViewController {
	/// Deletes the selected files.
	@objc func delete(_ sender: Any?) {
		removeSelectedFiles()
	}
	/// Deletes the clicked file or selection of files.
	@objc func deleteRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		removeSelectedFiles()
	}
	/// Shows the selected files in Finder.
	@objc func showInFinder(_ sender: Any?) {
		guard let dataController = dataController else { return }
		let selectedPaths = dataController.filesSelected.compactMap { $0.path }
		NSWorkspace.shared.activateFileViewerSelecting(selectedPaths)
	}
	/// Shows the clicked file or selection of files in Finder.
	@objc func showInFinderRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		showInFinder(sender)
	}
	/// Opens the selected files in DataGraph.
	@objc func openInDataGraph(_ sender: Any?) {
		guard let controller = controller else { return }
		guard let parentURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
			.appendingPathComponent("Graphs")
			.appendingPathComponent("Cache")
			else { return }
		if !FileManager.default.fileExists(atPath: parentURL.path) {
			do {
				try FileManager.default.createDirectory(at: parentURL, withIntermediateDirectories: true)
			} catch {
				print("[ERROR] Could not create ~/Library/Application Support/Graphs/Cache")
			}
		}
		guard let dataController = dataController else { return }
		
		defer {
			// Will be manipulating the graph view in order to render the files, make sure to set this view controller's graph controller back to the graph to be drawn
			controller.setDelegate(graphView)
		}
		
		dataController.filesSelected.forEach { file in
			// Name the file some (almost certainly) unique name.
			let name = UUID().uuidString
			let url = parentURL.appendingPathComponent("\(name).dgraph")
			
			// Try to create a controller
			guard let controller = dataController.graphTemplate(for: file)?.controller,
				let parser = dataController.parser(for: file),
				let parsedFile = parser.parse(file: file) else { return }
			
			let data = parsedFile.data
			
			let columns: [[NSString]] = data.columns(count: parsedFile.numberOfColumns)
				.map { dataColumn in
					return dataColumn.compactMap { $0 as NSString? }
			}

			columns.enumerated().forEach { (index, element) in
				controller.dataColumn(at: Int32(index + 1))?.setDataFrom(element)
			}
			
			controller.setDrawingView(graphView)
			
			do {
				
				try controller.write(to: url)
				NSWorkspace.shared.openFile(url.path, withApplication: "DataGraph")
			} catch {
				print("[ERROR] Failed to write data graph file: \(error)")
			}
		}
	}
	/// Opens the clicked file or selection of files in DataGraph.
	@objc func openInDataGraphRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		openInDataGraph(sender)
	}
	/// Saves the selected file in DataGraph.
	@objc func saveAsDataGraph(_ sender: Any?) {
		guard let controller = controller else { return }
		guard let window = view.window else { return }
		let savePanel = NSSavePanel()
		savePanel.allowedFileTypes = ["dgraph"]
		savePanel.beginSheetModal(for: window) { response in
			if response == .OK, let url = savePanel.url {
				do {
					try controller.write(to: url)
				} catch {
					print("[ERROR] Could not write datagraph file to \(url): \(error)")
				}
			}
		}
	}
	/// Saves the clicked file in DataGraph.
	@objc func saveAsDataGraphRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		saveAsDataGraph(sender)
	}
}

// MARK: Validations
extension FileListViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		// If the item does not have an action associated with it, then that item should be disabled. Ideally there should not be any items that don't have an action associated with them, but if there are by having them disabled there are two benefits:
		// 1. The user will not be able to click on the item, which they may expect to be doing something.
		// 2. The developer will be more likley to notice that an item is not configured with an action becuase it will be disabled.
		guard let action = item.action else { return false }
		
		switch action {
		case #selector(delete(_:)),
				 #selector(openInDataGraph(_:)):
			// When no item is selected, invalidate the action so that the user doesn't mistakenly think they are performing an action on an item/items when they are not
			return !tableView.hasEmptyRowSelection
		case #selector(deleteRow(_:)),
				 #selector(openInDataGraphRow(_:)):
			// When no item is selected, invalidate the action so that the user doesn't mistakenly think they are performing an action on an item/items when they are not
			return !tableView.hasEmptyClickRowSelection
		case #selector(showInFinderRow(_:)):
			guard !tableView.hasEmptyClickRowSelection else { return false }
			// Don't allow show in finder if all of the selected files no longer exist
			if tableView.selectedRowIndexes.contains(tableView.clickedRow) {
				// Right clicked on the selection, so will be showing all the files in the selection, which is equivelant to the selector showInFinder(_:)
				fallthrough
			} else if tableView.clickedRow >= 0 {
				// Otherwise will be selecting the row that was right clicked -- make sure that that directory has a valid path
				guard let file = dataController?.filesDisplayed[tableView.clickedRow] else { return false }
				guard let path = file.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			} else {
				// No selection, so don't validate
				return false
			}
		case #selector(showInFinder(_:)):
			// Don't allow show in finder if all of the selected files no longer exist
			guard !tableView.hasEmptyRowSelection else { return false }
			guard let dataController = dataController else { return false }
			return !dataController.filesSelected.noneSatisfy { file in
				// Returns true if it can open the file
				guard let path = file.path else { return false }
				return FileManager.default.fileExists(atPath: path.path)
			}
		case #selector(saveAsDataGraphRow(_:)):
			// Can only save one file at a time
			if tableView.selectedRowIndexes.contains(tableView.clickedRow) {
				// Right clicking on selection, so make sure there is only a selection of 1
				return tableView.selectedRowIndexes.count == 1
			} else {
				// Right clicking outside of the selection, so just make sure that the user is right clicking on a valid row
				return tableView.clickedRow >= 0
			}
		case #selector(saveAsDataGraph(_:)):
			// Can only save one file at a time
			return tableView.selectedRowIndexes.count == 1
		default:
			// Many actions can always be performed. Instead of switching over each one and returning true, we can by default return true and add swtich cases for when false should (sometimes) be returned
			return true
		}
	}
}
