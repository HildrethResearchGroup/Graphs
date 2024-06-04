//
//  InspectorCategoryOptionCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A table cell view for displaying a category in the inspector with a pop up button for a user selected option for that section.
class InspectorCategoryOptionCell: NSTableCellView {
	/// The popup button.
	@IBOutlet weak var popUpButton: NSPopUpButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorCategoryOptionCellDelegate?
	/// The action that is called when the pop up button's selection has changed.
	/// - Parameter popUpButton: The pop up button that has changed.
	@objc func popUpButtonAction(_ popUpButton: NSPopUpButton) {
		delegate?.popUpDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions for sub views, so that the target actions don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorCategoryOptionCellDelegate: AnyObject {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types. 
	/// Called when the pop up button's selection changed.
	/// - Parameter cell: The cell that the pop up view is in.
	@objc(inspectorCategoryOptionCellPopUpDidChangeState:)
	optional func popUpDidChangeState(_ cell: InspectorCategoryOptionCell)
}
