//
//  NotificationTextField.swift
//  Graphs
//
//  Created by Connor Barnes on 7/13/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension NSTextFieldDelegate {
	func textField(for notification: Notification) -> NSTextField? {
		return notification.object as? NSTextField
	}
}
