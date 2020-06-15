//
//  InspectorButton.swift
//  Graphs
//
//  Created by Connor Barnes on 6/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorButton: NSButton {
	@IBInspectable var selectedImage: NSImage?
	@IBInspectable var unselectedImage: NSImage?
	
	@IBInspectable var selectedTintColor: NSColor?
	@IBInspectable var unselectedTintColor: NSColor?
	
	@IBInspectable var tabIndex: Int = 0
	
	weak var group: InspectorButtonGroup? {
		willSet {
			group?.inspectorButtons.removeAll { $0 === self }
		}
		didSet {
			group?.inspectorButtons.append(self)
		}
	}

	fileprivate func setSelected() {
		image = selectedImage
		contentTintColor = selectedTintColor
	}

	fileprivate func setUnselected() {
		image = unselectedImage
		contentTintColor = unselectedTintColor
	}
	
	override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
		
		group?.select(inspectorButton: self)
		
		return super.sendAction(action, to: target)
	}
}

protocol InspectorButtonGroup: class {
	var inspectorButtons: [InspectorButton] { get set }
	
	var tabView: NSTabView! { get }
	
	func didSelect(button: InspectorButton)
}

extension InspectorButtonGroup {
	func didSelect(button: InspectorButton) { }
	
	func select(inspectorButton: InspectorButton?) {
		guard let inspectorButton = inspectorButton else {
			inspectorButtons.forEach { $0.setUnselected() }
			return
		}
		guard inspectorButton.group === self else { return }
		
		inspectorButtons.forEach { $0.setUnselected() }
		inspectorButton.setSelected()
		
		tabView.selectTabViewItem(at: inspectorButton.tabIndex)
		
		didSelect(button: inspectorButton)
	}
}
