//
//  File Inspector Cells.swift
//  Graphs
//
//  Created by Connor Barnes on 6/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class FileInspectorCategoryOptionCell: NSTableCellView {
	@IBOutlet weak var popUpButton: NSPopUpButton!
}

class FileInspectorNameAndLocationCell: NSTableCellView {
	@IBOutlet weak var nameTextField: NSTextField!
	@IBOutlet weak var pathTextField: NSTextField!
}

class FileInspectorTemplatesCell: NSTableCellView {
	@IBOutlet weak var parserPopUpButton: NSPopUpButton!
	@IBOutlet weak var graphPopUpButton: NSPopUpButton!
}

class FileInspectorDetailsCell: NSTableCellView {
	@IBOutlet weak var textView: NSTextView!
}
