//
//  InspectorTwoPopUpButtonsCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTwoPopUpButtonsCell: NSTableCellView {
	@IBOutlet weak var firstPopUpButton: NSPopUpButton!
	@IBOutlet weak var secondPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var delegate: InspectorTwoPopUpButtonsCellDelegate?
	
	@objc func firstPopUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.firstPopUpButtonDidChange?(self)
	}
	
	@objc func secondPopUpButtonAction(_ sender: NSPopUpButton) {
		delegate?.secondPopUpButtonDidChange?(self)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		firstPopUpButton.action = #selector(firstPopUpButtonAction(_:))
		secondPopUpButton.action = #selector(secondPopUpButtonAction(_:))
		
		firstPopUpButton.target = self
		secondPopUpButton.target = self
	}
}

// MARK: Delegate
@objc protocol InspectorTwoPopUpButtonsCellDelegate: class {
	@objc(inspectorTwoPopUpButtonsCellFirstPopUpButtonDidChange:)
	optional func firstPopUpButtonDidChange(_ cell: InspectorTwoPopUpButtonsCell)
	@objc(inspectorTwoPopUpButtonsCellSecondPopUpButtonDidChange:)
	optional func secondPopUpButtonDidChange(_ Cell: InspectorTwoPopUpButtonsCell)
}
