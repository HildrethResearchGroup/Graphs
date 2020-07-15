//
//  InspectorTwoPopUpButtonsCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoPopUpButtonsCell: NSTableCellView {
	@IBOutlet weak var firstPopUpButton: NSPopUpButton!
	@IBOutlet weak var secondPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var delegate: InspectorTwoPopUpButtonsCellDelegate?
}

// MARK: Delegate
@objc protocol InspectorTwoPopUpButtonsCellDelegate: class {
	
}
