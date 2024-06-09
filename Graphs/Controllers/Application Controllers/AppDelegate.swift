//
//  AppDelegate.swift
//  Graphs
//
//  Created by Owen Hildreth on 4/30/24.
//

import Foundation

// ADD
import Cocoa

// Notice that this is an NSObject
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// Determines whether the application should terminate after the last window is closed.
    /// - Parameter sender: The application object that is controlling the application.
    /// - Returns: A Boolean value indicating whether the application should terminate.
    ///            Returning `true` will cause the application to terminate.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
