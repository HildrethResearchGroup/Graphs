//
//  InspectorTwoTextFieldsCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoTextFieldsCell: NSTableCellView {
	/// The first text field.
	@IBOutlet weak var firstTextField: NSTextField!
	/// The second text field.
	@IBOutlet weak var secondTextField: NSTextField!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorTwoTextFieldsCellDelegate?
	
	override func awakeFromNib() {
		// awakeFromNib is overriden to assign the tdelegates for sub views, so that the delegates don't need to be manually applied in interface builder / programatically.
		super.awakeFromNib()
		firstTextField.delegate = self
		secondTextField.delegate = self
	}
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorTwoTextFieldsCellDelegate: class {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the first text field has ended editing.
	/// - Parameter cell: The cell that the text field is in.
	@objc(inspectorTwoTextFieldsCellFirstTextFieldDidEndEditing:)
	optional func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell)
	/// Called when the second text field has ended editing.
	/// - Parameter cell: The cell that the text field is in.
	@objc(inspectorTwoTextFieldsCellSecondTextFieldDidEndEditing:)
	optional func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell)
}

// MARK: NSTextFieldDelegate
extension InspectorTwoTextFieldsCell: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ notification: Notification) {
		switch textField(for: notification)! {
		case firstTextField:
			delegate?.firstTextFieldDidEndEditing?(self)
		case secondTextField:
			delegate?.secondTextFieldDidEndEditing?(self)
		default:
			break
		}
	}
}
