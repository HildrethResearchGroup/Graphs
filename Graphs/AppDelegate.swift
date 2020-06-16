//
//  AppDelegate.swift
//  Graphs
//
//  Created by Connor Barnes on 4/23/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		DataController.initialize {
			print("Core Data loaded")
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		DataController.shared?.saveImmediatley()
	}
	
	func applicationWillResignActive(_ notification: Notification) {
		DataController.shared?.saveImmediatley()
	}
}

