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
    var preferencesController: NSWindowController?
    
    
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Start loading the saved state as soon as the app launches
		DataController.initialize {
			print("Core Data loaded")
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Save any changes before terminating the app
		DataController.shared?.saveImmediatley()
	}
	
	func applicationWillResignActive(_ notification: Notification) {
		// When moving the app to the background, save any changes
		DataController.shared?.saveImmediatley()
	}
    
    
    @IBAction func showPreferences(_ sender: Any) {
            
            if self.preferencesController == nil {
                let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
                self.preferencesController = storyboard.instantiateInitialController() as? NSWindowController
            }
            
            if let controller = self.preferencesController {
                controller.showWindow(sender)
            }
        }
}

