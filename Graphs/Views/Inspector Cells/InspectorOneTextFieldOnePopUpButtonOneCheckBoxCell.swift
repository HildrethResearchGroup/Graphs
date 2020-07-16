//
//  InspectorOneTextFieldOnePopUpButtonCellOneCheckBoxCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell: NSTableCellView {
	@IBOutlet weak var popUpButton: NSPopUpButton!
	@IBOutlet weak var checkBox: NSButton!
	
	@IBOutlet weak var delegate: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCellDelegate?
	
	@objc func popUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.popUpButtonDidChange?(self)
	}
	
	@objc func checkBoxAction(_ sender: NSPopUpButton) {
		delegate?.checkBoxDidChangeState?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		popUpButton.action = #selector(popUpButtonAction(_:))
		popUpButton.target = self
		checkBox.action = #selector(checkBoxAction(_:))
		checkBox.target = self
	}
}

// MARK: Delegate
@objc protocol InspectorOneTextFieldOnePopUpButtonOneCheckBoxCellDelegate {
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellPopUpButtonDidChange:) optional func popUpButtonDidChange(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellCheckBoxDidChangeState:) optional func checkBoxDidChangeState(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
	@objc(inspectorOneTextFieldOnePopUpButtonOneCheckBoxCellTextFieldDidEndEditing:) optional func textFieldDidEndEditing(_ cell: InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell)
}

extension InspectorOneTextFieldOnePopUpButtonOneCheckBoxCell: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ obj: Notification) {
		delegate?.textFieldDidEndEditing?(self)
	}
}
