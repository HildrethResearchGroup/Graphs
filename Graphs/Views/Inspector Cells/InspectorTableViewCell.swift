//
//  InspectorTableViewCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTableViewCell: NSTableCellView {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var addButton: NSButton!
	@IBOutlet weak var removeButton: NSButton!
	
	@IBOutlet weak var delegate: InspectorTableViewCellDelegate?
	
	@objc func addButtonAction(_ sender: NSButton) {
		delegate?.addButtonPressed?(self)
	}
	
	@objc func removeButtonAction(_ sender: NSButton) {
		delegate?.removeButtonPressed?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		addButton.action = #selector(addButtonAction(_:))
		removeButton.action = #selector(removeButtonAction(_:))
		addButton.target = self
		removeButton.target = self
	}
}

extension InspectorTableViewCell: NSTextFieldDelegate, NSTokenFieldDelegate {
	func controlTextDidEndEditing(_ notification: Notification) {
		guard let textField = self.textField(for: notification) else { return }
		let row = tableView.row(for: textField)
		guard row >= 0 else { return }
		delegate?.controlTextDidEndEditing?(self, textField: textField, at: row)
	}
}

// MARK: Delegate
@objc protocol InspectorTableViewCellDelegate {
	@objc optional func addButtonPressed(_ cell: InspectorTableViewCell)
	@objc optional func removeButtonPressed(_ cell: InspectorTableViewCell)
	@objc optional func controlTextDidEndEditing(_ cell: InspectorTableViewCell, textField: NSTextField, at row: Int)
}
