//
//  InspectorTwoTextFieldsOnePopUpButtonCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoTextFieldsOnePopUpButtonCell: NSTableCellView {
	/// The first text field.
	@IBOutlet weak var firstTextField: NSTextField!
	/// The second text field.
	@IBOutlet weak var secondTextField: NSTextField!
	/// The pop up button
	@IBOutlet weak var popUpButton: NSPopUpButton!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorTwoTextFieldsOnePopUpButtonCellDelegate?
	/// Called when the pop up button's selection changes.
	@objc func popUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.popUpButtonDidChange?(self)
	}
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the target actions and delegates for sub views, so that the target actions and delegates don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		firstTextField.delegate = self
		secondTextField.delegate = self
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorTwoTextFieldsOnePopUpButtonCellDelegate {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the first text field ends editing.
	/// - Parameter cell: The cell that the text field is in.
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellFirstTextFieldDidEndEditing:)
	optional func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
	/// Called when the second text field ends editing.
	/// - Parameter cell: The cell that the text field is in.
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellSecondTextFieldDidEndEditing:)
	optional func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
	/// Called when the pop up button's selection changes.
	/// - Parameter cell: The cell that the pop up button is in.
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellPopUpButtonDidChange:)
	optional func popUpButtonDidChange(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
}

// MARK: NSTextFieldDelegate
extension InspectorTwoTextFieldsOnePopUpButtonCell: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ notification: Notification) {
		guard let textField = textField(for: notification) else { return }
		switch textField {
		case firstTextField:
			delegate?.firstTextFieldDidEndEditing?(self)
		case secondTextField:
			delegate?.secondTextFieldDidEndEditing?(self)
		default:
			break
		}
	}
}
