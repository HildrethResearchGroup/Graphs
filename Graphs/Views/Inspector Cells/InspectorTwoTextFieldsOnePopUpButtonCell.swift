//
//  InspectorTwoTextFieldsOnePopUpButtonCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoTextFieldsOnePopUpButtonCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
	@IBOutlet weak var popUpButton: NSPopUpButton!
	
	@IBOutlet weak var delegate: InspectorTwoTextFieldsOnePopUpButtonCellDelegate?
}

// MARK: Delegate
@objc protocol InspectorTwoTextFieldsOnePopUpButtonCellDelegate {
	
}
