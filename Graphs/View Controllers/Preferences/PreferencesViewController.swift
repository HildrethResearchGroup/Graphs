//
//  PreferencesViewController.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/28/23.
//  Copyright © 2023 Connor Barnes. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var button_add: NSButton!
    
    @IBOutlet weak var button_subtract: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the size for each views
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Update window title with the active TabView Title
        if let title = self.title {
            self.parent?.view.window?.title = title
        }
    }
}
