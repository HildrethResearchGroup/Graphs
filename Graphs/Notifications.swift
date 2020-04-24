//
//  Notifications.swift
//  Graphs
//
//  Created by Connor Barnes on 4/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

extension Notification.Name {
	/// A notification that is fired when Core Data's store has loaded the application's data.
	static let storeLoaded = Notification.Name(rawValue: "storeLoaded")
}
