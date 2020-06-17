//
//  Inspector Cells.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorCategoryOptionCell: NSTableCellView {
	@IBOutlet weak var popUpButton: NSPopUpButton!
}

class InspectorTwoTextFieldsCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
}

class InspectorTwoPopUpButtonsCell: NSTableCellView {
	@IBOutlet weak var firstPopUpButton: NSPopUpButton!
	@IBOutlet weak var secondPopUpButton: NSPopUpButton!
}

class InspectorTextViewCell: NSTableCellView {
	@IBOutlet weak var textView: NSTextView!
}
