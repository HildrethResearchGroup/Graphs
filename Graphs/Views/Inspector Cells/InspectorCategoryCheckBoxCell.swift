//
//  InspectorCategoryCheckBoxCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorCategoryCheckBoxCell: NSTableCellView {
	@IBOutlet weak var checkBox: NSButton!
	
	@IBOutlet weak var delegate: InspectorCategoryCheckBoxCellDelegate?
	
	@objc func checkBoxAction(_ sender: NSButton) {
		delegate?.checkBoxDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		checkBox.action = #selector(checkBoxAction(_:))
	}
}

// MARK: Delegate
@objc protocol InspectorCategoryCheckBoxCellDelegate: class {
	@objc optional func checkBoxDidChangeState(_ cell: InspectorCategoryCheckBoxCell)
}
