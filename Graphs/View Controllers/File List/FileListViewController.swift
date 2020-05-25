//
//  FileListViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 5/24/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class FileListViewController: NSViewController {
	/// The table view.
	@IBOutlet weak var tableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerObservers()
	}
	
	func registerObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(directorySelectionDidChange), name: .directorySelectionChanged, object: nil)
		
	}
	
	@objc func directorySelectionDidChange() {
		
	}
}
