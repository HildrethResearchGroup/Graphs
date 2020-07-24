//
//  InspectorCategoryCheckBoxCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A table cell view for displaying a category in the inspector with a check box.
class InspectorCategoryCheckBoxCell: NSTableCellView {
	/// The check box.
	@IBOutlet weak var checkBox: NSButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorCategoryCheckBoxCellDelegate?
	/// Called when the check box is pressed.
	@objc func checkBoxAction(_ sender: NSButton) {
		delegate?.checkBoxDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions for sub views, so that the target actions don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		checkBox.action = #selector(checkBoxAction(_:))
		checkBox.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorCategoryCheckBoxCellDelegate: class {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the check box is pressed.
	/// - Parameter cell: The cell that the check box is in.
	@objc(inspectorCategoryCheckBoxCellCheckBoxDidChangeState:)
	optional func checkBoxDidChangeState(_ cell: InspectorCategoryCheckBoxCell)
}
