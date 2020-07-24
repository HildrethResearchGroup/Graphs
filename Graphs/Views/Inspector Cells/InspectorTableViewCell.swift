//
//  InspectorTableViewCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTableViewCell: NSTableCellView {
	/// The table view.
	@IBOutlet weak var tableView: NSTableView!
	/// The add button.
	@IBOutlet weak var addButton: NSButton!
	/// The remove button.
	@IBOutlet weak var removeButton: NSButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorTableViewCellDelegate?
	/// Called when the add button is pressed.
	@objc func addButtonAction(_ sender: NSButton) {
		delegate?.addButtonPressed?(self)
	}
	/// Called when the remove button is pressed.
	@objc func removeButtonAction(_ sender: NSButton) {
		delegate?.removeButtonPressed?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions for sub views, so that the target actions don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		addButton.action = #selector(addButtonAction(_:))
		removeButton.action = #selector(removeButtonAction(_:))
		addButton.target = self
		removeButton.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorTableViewCellDelegate {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the add button is pressed.
	/// - Parameter cell: The cell that the button is in.
	@objc(inspectorTableViewCellAddButtonPressed:)
	optional func addButtonPressed(_ cell: InspectorTableViewCell)
	/// Called when the remove button is pressed.
	/// - Parameter cell: The cell that the button is in.
	@objc(inspectorTableViewCellRemoveButtonPressed:)
	optional func removeButtonPressed(_ cell: InspectorTableViewCell)
	/// Called when a text field or token field within the cell's table view ends editing.
	/// - Parameters:
	///   - cell: The cell that the table view is in.
	///   - textField: The text field or token field that ended editing.
	///   - row: The row of the table view that the text field or token field is located in.
	@objc(inspectorTableViewCellControlTextDidEndEditing:textField:atRow:)
	optional func controlTextDidEndEditing(_ cell: InspectorTableViewCell, textField: NSTextField, at row: Int)
}

// MARK: NSTextFieldDelegate & NSTokenFieldDelegate
extension InspectorTableViewCell: NSTextFieldDelegate, NSTokenFieldDelegate {
	func controlTextDidEndEditing(_ notification: Notification) {
		guard let textField = self.textField(for: notification) else { return }
		let row = tableView.row(for: textField)
		guard row >= 0 else { return }
		delegate?.controlTextDidEndEditing?(self, textField: textField, at: row)
	}
}
