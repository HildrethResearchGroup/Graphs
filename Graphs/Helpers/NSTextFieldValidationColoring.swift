//
//  NSTextFieldValidationColoring.swift
//  Graphs
//
//  Created by Connor Barnes on 7/15/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTextField {
	private static var origionalColor: [NSTextField: NSColor?] = [:]
	private static var isValid: [NSTextField: Bool] = [:]
	
	func setValid(_ valid: Bool) {
		if valid {
			textColor = NSTextField.origionalColor[self] ?? .labelColor
			NSTextField.isValid[self] = true
		} else {
			if NSTextField.isValid[self] ?? true {
				NSTextField.origionalColor[self] = textColor
			}
			textColor = .systemRed
			NSTextField.isValid[self] = false
		}
	}
}
