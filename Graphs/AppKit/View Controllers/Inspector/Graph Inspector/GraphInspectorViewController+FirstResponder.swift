//
//  GraphInspectorViewController+FirstResponder.swift
//  Graphs
//
//  Created by Connor Barnes on 8/9/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension GraphInspectorViewController {
	/// Deletes the selected graph templates.
	@objc func delete(_ sender: Any?) {
		removeSelectedGraphTemplates()
	}
	/// Deletes the clicked graph template or selection of graph templates.
	@objc func deleteRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		removeSelectedGraphTemplates()
	}
	/// Imports a new graph template.
	@objc func importGraphTemplate(_ sender: Any?) {
		addGraphTemplate(sender)
	}
	/// Shows the selected graph templates in Finder.
	@objc func showInFinder(_ sender: Any?) {
		guard let dataController = dataController else { return }
		let selectedPaths = tableView.selectedRowIndexes.compactMap { index in
			dataController.graphTemplates[index].path
		}
		NSWorkspace.shared.activateFileViewerSelecting(selectedPaths)
	}
	/// Shows the clicked graph template or selection of graph templates in Finder.
	@objc func showInFinderRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		showInFinder(sender)
	}
	/// Opens the selected graph templates in DataGraph.
	@objc func openInDataGraph(_ sender: Any?) {
		guard let dataController = dataController else { return }
		let selectedPaths = tableView.selectedRowIndexes.compactMap { index in
			dataController.graphTemplates[index].path
		}
		queue.async {
			selectedPaths.forEach { path in
				NSWorkspace.shared.openFile(path.path, withApplication: "DataGraph")
			}
		}
	}
	/// Opens the clicked graph template or selection of graph templates in DataGraph.
	@objc func openInDataGraphRow(_ sender: Any?) {
		selectClickedRowIfNotInSelection(in: tableView)
		openInDataGraph(sender)
	}
}

// MARK: Validations
extension GraphInspectorViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
		case #selector(deleteRow(_:)),
				 #selector(showInFinderRow(_:)),
				 #selector(openInDataGraphRow(_:)):
			// When no item is selected, invalidate the action so that the user doesn't mistakenly think they are performing an action on an item/items when they are not
			return !tableView.hasEmptyClickRowSelection
		case #selector(delete(_:)),
				 #selector(showInFinder(_:)),
				 #selector(openInDataGraph(_:)):
			// When no item is selected, invalidate the action so that the user doesn't mistakenly think they are performing an action on an item/items when they are not
			return !tableView.hasEmptyRowSelection
		default:
			return true
		}
	}
}
