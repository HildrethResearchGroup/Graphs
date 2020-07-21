//
//  NSTextFieldValidationColoring.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTextField {
	/// A dictionary mapping textfield's to their origional text colors.
	private static var origionalColor: [NSTextField: NSColor?] = [:]
	/// A dictionary mapping textfield's to whether or not their contents are valid.
	private static var isValid: [NSTextField: Bool] = [:]
	/// Sets a given's textfields contents as valid or not. Invalid contents are displayed as red.
	/// - Parameter valid: Whether the contents of the text field are valid or not.
	func setValid(_ valid: Bool) {
		if valid {
			// Restore the origional text color, otherwise default to the system default label color
			textColor = NSTextField.origionalColor[self] ?? .labelColor
			NSTextField.isValid[self] = true
		} else {
			if NSTextField.isValid[self] ?? true {
				// Save the current text color so that if the text field is marked as valid in the future, the text color can be restored
				NSTextField.origionalColor[self] = textColor
			}
			// Set the text color to red for invalid text.
			textColor = .systemRed
			NSTextField.isValid[self] = false
		}
	}
}
