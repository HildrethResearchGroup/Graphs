//
//  DataInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

class DataInspectorViewController: NSViewController {
	@IBOutlet weak var tabSegmentedControl: NSSegmentedControl!
	@IBOutlet weak var tabView: NSTabView!
	@IBOutlet var textView: NSTextView!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var errorLabel: NSTextField!
	
	var file: File? {
		didSet {
			prepareView()
		}
	}
	
	@IBAction func tabSegmentedControlChanged(_ sender: NSSegmentedControl) {
		guard sender.selectedSegment >= 0 else {
			print("[WARNING] No tab selected in DataInspectorViewController")
			return
		}
		
		let tag = sender.tag(forSegment: sender.selectedSegment)
		guard (0...1).contains(tag) else {
			print("[WARNING] Invalid tag for segmented control in DataInspectorViewController")
			return
		}
		
		tabView.selectTabViewItem(at: tag)
	}
}

// MARK: Helpers
extension DataInspectorViewController {
	func prepareView() {
		guard let url = file?.path else { return }
		do {
			let fileContents = try String.detectingEncoding(ofContents: url).string
			textView.string = fileContents
			errorLabel.isHidden = true
		} catch {
			print("[WARNING] Failed to read file at path \(url.path): \(error)")
			textView.string = ""
			errorLabel.isHidden = false
		}
	}
}
