//
//  NotificationTextField.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTextFieldDelegate {
	/// Returns the `NSTextField` associed with a notification for `NSTextFieldDelegate` methods.
	/// - Parameter notification: The notification.
	/// - Returns: The `NSTextField` object of the notification if it has one, otherwise `nil`.
	func textField(for notification: Notification) -> NSTextField? {
		return notification.object as? NSTextField
	}
}
