//
//  InspectorTextViewCell.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class InspectorTextViewCell: NSTableCellView {
	/// The text view.
	@IBOutlet weak var textView: NSTextView!
	/// The view's delegate.
	@IBOutlet weak var delegate: InspectorTextViewCellDelegate?
}

// MARK: Delegate
/// A set of optional methods to respond to changes of state for the cell.
@objc protocol InspectorTextViewCellDelegate: class {
	// Custom Objective-C names are given becuase otherwise there would be certain cell delegates with matching signatures, which would prevent them from being simultaneously conformed to by types.
	/// Called when the text view ends editing.
	/// - Parameter cell: The cell that the text view is in.
	@objc(inspectorTextViewCellTextDidEndEditing:)
	optional func textDidEndEditing(_ cell: InspectorTextViewCell)
}

// MARK: NSTextViewDelegate
extension InspectorTextViewCell: NSTextViewDelegate {
	func textDidEndEditing(_ notification: Notification) {
		delegate?.textDidEndEditing?(self)
	}
}
