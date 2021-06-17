//
//  ProgressCellView.swift
//  Graphs
//
//  Created by Alperen Ugus, Murat Tuter, Sukru Kiymaci on 31.05.2021.
//  Copyright © 2021 Connor Barnes. All rights reserved.
//

import Cocoa

class ProgressCellView: NSTableCellView {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var readyLabel: NSTextField!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
