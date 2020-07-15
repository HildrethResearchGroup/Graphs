//
//  InspectorTextViewCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTextViewCell: NSTableCellView {
	@IBOutlet weak var textView: NSTextView!
	
	@IBOutlet weak var delegate: InspectorTextViewCellDelegate?
}

// MARK: Delegate
@objc protocol InspectorTextViewCellDelegate: class {
	
}
