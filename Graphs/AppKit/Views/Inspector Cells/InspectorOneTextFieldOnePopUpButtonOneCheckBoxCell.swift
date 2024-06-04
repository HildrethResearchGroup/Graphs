//
//  InspectorOneTextFieldOnePopUpButtonCellOneCheckBoxCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell: NSTableCellView {
	/// The pop up button.
	@IBOutlet weak var popUpButton: NSPopUpButton!
	/// The check box.
	@IBOutlet weak var checkBox: NSButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCellDelegate?
	/// Called when the first pop up button's selection changes.
	@objc func popUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.popUpButtonDidChange?(self)
	}
	/// Called when the check box is pressed.
	@objc func checkBoxAction(_ sender: NSPopUpButton) {
		delegate?.checkBoxDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions for sub views, so that the target actions don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
		checkBox.action = #selector(checkBoxAction(_:))
		checkBox.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorOneTextFieldOnePopUpButtonOneCheckBoxCellDelegate {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the pop up button's state changes.
	/// - Parameter cell: The cell that the pop up button is in.
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellPopUpButtonDidChange:)
	optional func popUpButtonDidChange(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
	/// Called when the check box is pressed.
	/// - Parameter cell: The cell that the check box is in.
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellCheckBoxDidChangeState:)
	optional func checkBoxDidChangeState(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
	/// Called when the text field ends editing.
	/// - Parameter cell: The cell that the text field is in.
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellTextFieldDidEndEditing:)
	optional func textFieldDidEndEditing(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
}

// MARK: NSTextFieldDelegate
extension InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ obj: Notification) {
		delegate?.textFieldDidEndEditing?(self)
	}
}
