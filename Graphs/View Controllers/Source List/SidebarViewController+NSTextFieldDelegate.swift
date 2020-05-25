//
//  SidebarViewController+TextFieldDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 5/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

// MARK: NSTextFieldDelegate
extension SidebarViewController: NSTextFieldDelegate {
	/// Called when an NSTextField ends editing.
	func controlTextDidEndEditing(_ notification: Notification) {
		// Only the NSTextField in the NSTableViewCell should have this controller as its delegate -- no other subclasses of NSControl should thus be calling this method.
		guard let textField = notification.object as? NSTextField else {
			print("[WARNING] A subclass of NSControl has called controlTextDidEndEditing(_:) that is not an NSTextField. Only the NSTextField in the data cell of the NSTableViewCell should have its delegate set to the SidebarViewController.")
			return
		}
		
		let newName = textField.stringValue
		
		// In order to determine the Directory instance that the text field is referencing the following chain is used:
		// The Edited NSTableView -> The container NSTableViewCell -> The row index of the cell -> The item of that cell -> The directory that item represents
		guard let tableViewCell = textField.superview else {
			print("[WARNING] NSOutlineView could not find the table view cell of the editing text field.")
			return
		}
		let row = sidebar.row(for: tableViewCell)
		guard row != -1 else {
			print("[WARNING] NSOutlineView could not find the row of the editing text field.")
			return
		}
		let directory = directoryFromItem(sidebar.item(atRow: row))
		
		directory?.customDisplayName = newName
		dataController?.setNeedsSaved()
	}
}
