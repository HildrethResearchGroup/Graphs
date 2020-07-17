//
//  InspectorCategoryOptionCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorCategoryOptionCell: NSTableCellView {
	@IBOutlet weak var popUpButton: NSPopUpButton!
	
	@IBOutlet weak var delegate: InspectorCategoryOptionCellDelegate?
	
	@objc func popUpButtonAction(_ popUpButton: NSPopUpButton) {
		delegate?.popUpDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
	}
}

// MARK: Delegate
@objc protocol InspectorCategoryOptionCellDelegate: class {
	@objc(inspectorCategoryOptionCellPopUpDidChangeState:)
	optional func popUpDidChangeState(_ cell: InspectorCategoryOptionCell)
}
