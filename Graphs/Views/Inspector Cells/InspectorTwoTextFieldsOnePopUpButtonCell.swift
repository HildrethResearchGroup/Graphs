//
//  InspectorTwoTextFieldsOnePopUpButtonCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoTextFieldsOnePopUpButtonCell: NSTableCellView {
	@IBOutlet weak var firstTextField: NSTextField!
	@IBOutlet weak var secondTextField: NSTextField!
	@IBOutlet weak var popUpButton: NSPopUpButton!
	
	@IBOutlet weak var delegate: InspectorTwoTextFieldsOnePopUpButtonCellDelegate?
	
	@objc func popUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.popUpButtonDidChange?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		firstTextField.delegate = self
		secondTextField.delegate = self
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
	}
}

// MARK: Delegate
@objc protocol InspectorTwoTextFieldsOnePopUpButtonCellDelegate {
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellFirstTextFieldDidEndEditing:)
	optional func firstTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellSecondTextFieldDidEndEditing:)
	optional func secondTextFieldDidEndEditing(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
	@objc(inspectorTwoTextFieldsOnePopUpButtonCellPopUpButtonDidChange:)
	optional func popUpButtonDidChange(_ cell: InspectorTwoTextFieldsOnePopUpButtonCell)
}

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
