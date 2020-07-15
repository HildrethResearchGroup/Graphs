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
	
	@IBOutlet weak var delegate: InspectorTableViewCellDelegate? {
		didSet {
			tableView.delegate = delegate
			tableView.dataSource = delegate
		}
	}
	
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
		tableView.delegate = delegate
		tableView.dataSource = delegate
	}
}

// MARK: Delegate
@objc protocol InspectorTableViewCellDelegate: NSTableViewDelegate, NSTableViewDataSource {
	@objc optional func addButtonPressed(_ cell: InspectorTableViewCell)
	@objc optional func removeButtonPressed(_ cell: InspectorTableViewCell)
}
