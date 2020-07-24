//
//  InspectorTwoPopUpButtonsCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoPopUpButtonsCell: NSTableCellView {
	/// The first pop up button.
	@IBOutlet weak var firstPopUpButton: NSPopUpButton!
	/// The second pop up button.
	@IBOutlet weak var secondPopUpButton: NSPopUpButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorTwoPopUpButtonsCellDelegate?
	/// Called when the first pop up button's selection changes.
	@objc func firstPopUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.firstPopUpButtonDidChange?(self)
	}
	/// Called when the second pop up button's selection changes.
	@objc func secondPopUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.secondPopUpButtonDidChange?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions for sub views, so that the target actions don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		
		firstPopUpButton.action = #selector(firstPopUpButtonAction(_:))
		secondPopUpButton.action = #selector(secondPopUpButtonAction(_:))
		
		firstPopUpButton.target = self
		secondPopUpButton.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorTwoPopUpButtonsCellDelegate: class {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the first pop up button's selection changed.
	/// - Parameter cell: The cell that the pop up button is in.
	@objc(inspectorTwoPopUpButtonsCellFirstPopUpButtonDidChange:)
	optional func firstPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell)
	/// Called when the second pop up button's selection changed.
	/// - Parameter cell: The cell that the pop up button is in.
	@objc(inspectorTwoPopUpButtonsCellSecondPopUpButtonDidChange:)
	optional func secondPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell)
}
