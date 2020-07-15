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
}

// MARK: Delegate
@objc protocol InspectorCategoryCheckBoxCellDelegate: class {
	
}
