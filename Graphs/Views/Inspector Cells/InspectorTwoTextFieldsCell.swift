//
//  InspectorTwoTextFieldsCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoTextFieldsCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
	
	@IBOutlet weak var delegate: InspectorTwoTextFieldsCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		firstTextField.delegate = self
		secondTextField.delegate = self
	}
}

// MARK: Delegate
@objc protocol InspectorTwoTextFieldsCellDelegate: class {
	@objc optional func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell)
	@objc optional func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsCell)
}

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
