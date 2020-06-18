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

class InspectorTableCell: NSTableCellView {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var addItemButton: NSButton!
	@IBOutlet weak var removeItemButton: NSButton!
}

class InspectorCategoryButtonCell: NSTableCellView {
	@IBOutlet weak var button: NSButton!
}

class InspectorTwoNumberFieldsOneOptionCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
	@IBOutlet weak var firstStepper: NSStepper!
	@IBOutlet weak var secondStepper: NSStepper!
	@IBOutlet weak var popUpOption: NSPopUpButton!
}

class InspectorTwoNumberFieldsOneOptionOnePopUpCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
	@IBOutlet weak var firstStepper: NSStepper!
	@IBOutlet weak var secondStepper: NSStepper!
	@IBOutlet weak var popUpOption: NSPopUpButton!
	@IBOutlet weak var popUpButton: NSPopUpButton!
}

class InspectorOneNumberFieldOnePopUpCell: NSTableCellView {
	@IBOutlet weak var stepper: NSStepper!
	@IBOutlet weak var popUpButton: NSPopUpButton!
}

class InspectorOneNumberFieldOneOptionCell: NSTableCellView {
	@IBOutlet weak var stepper: NSStepper!
	@IBOutlet weak var popUpOption: NSPopUpButton!
}
