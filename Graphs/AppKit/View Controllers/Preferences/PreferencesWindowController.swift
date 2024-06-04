//
//  PreferencesWindowController.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/23.
//  Copyright © 2023 Connor Barnes. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        // Hide the window instead of closing
        self.window?.orderOut(sender)
        return false
    }
    
}
