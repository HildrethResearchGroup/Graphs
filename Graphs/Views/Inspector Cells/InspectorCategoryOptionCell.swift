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
}

// MARK: Delegate
@objc protocol InspectorCategoryOptionCellDelegate: class {
	
}
