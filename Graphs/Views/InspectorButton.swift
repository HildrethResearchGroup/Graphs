//
//  InspectorButton.swift
//  Graphs
//
//  Created by Connor Barnes on 6/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A button that is used as a tab item for the inspector view.
class InspectorButton: NSButton {
	// Selected items are given a thicker line width for certain strokes, so an image for both selection states are needed
	/// The image to display when the item is selected.
	@IBInspectable var selectedImage: NSImage?
	/// The image to display when the item is not selected.
	@IBInspectable var unselectedImage: NSImage?
	/// The tint color of the image when the item is selected.
	@IBInspectable var selectedTintColor: NSColor?
	/// The tint color of the image when the item is not selected.
	@IBInspectable var unselectedTintColor: NSColor?
	/// The index of the tab view that this tab maps to.
	@IBInspectable var tabIndex: Int = 0
	/// The button group that the item belongs to. The button group manages selecting the proper tab view when a button is pressed.
	weak var group: InspectorButtonGroup? {
		willSet {
			// Before assigning this button to a group, remove this button from its current group.
			group?.inspectorButtons.removeAll { $0 === self }
		}
		didSet {
			group?.inspectorButtons.append(self)
		}
	}
	/// Marks this button as being selected, and updates its appearence.
	fileprivate func setSelected() {
		image = selectedImage
		contentTintColor = selectedTintColor
	}
	/// Marks this button as not being selected, and updates its appearence.
	fileprivate func setUnselected() {
		image = unselectedImage
		contentTintColor = unselectedTintColor
	}
	
	override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
		// The button is about to send its action -- this happens when the button is pressed. Notify the button group that this button was selected
		group?.select(inspectorButton: self)
		return super.sendAction(action, to: target)
	}
}

/// A group of buttons that map to a tab view.
protocol InspectorButtonGroup: class {
	/// The buttons which belong to the group and determine which tab is displayed.
	var inspectorButtons: [InspectorButton] { get set }
	/// The tab view that holds the views that the buttons map to.
	var tabView: NSTabView! { get }
	/// Called when a button is pressed.
	///
	/// - Parameter button: The button that was pressed.
	func didSelect(button: InspectorButton)
}

extension InspectorButtonGroup {
	// Leave an empty implementation for didSelect to make it an optional requirement
	func didSelect(button: InspectorButton) { }
	/// Selectes the given button and displays its associated tab item.
	/// - Parameter inspectorButton: The button to select.
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
