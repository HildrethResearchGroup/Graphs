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
	@IBOutlet var textView: LineNumberedTextView!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var errorLabel: NSTextField!
	
	var file: File? {
		didSet {
			// TODO: This needs to be called when the parser changes
			parsedFile = parseFile()
			prepareView()
		}
	}
	
	var parsedFile: ParsedFile?
	
	override func viewDidLoad() {
		// Enable horizontal scrolling to prevent word wraps
		textView.maxSize = NSSize(width: 1.0e7, height: 1.0e7)
		textView.isHorizontallyResizable = true
		textView.textContainer?.widthTracksTextView = false
		textView.textContainer?.containerSize = NSSize(width: 1.0e7, height: 1.0e7)
		
		// Add unlimited tab stops to prevent wrapping from tabs
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.defaultTabInterval = 36.0
		paragraphStyle.tabStops = []
		textView.defaultParagraphStyle = paragraphStyle
		
		// Add line numbers
		if let scrollView = textView.enclosingScrollView {
			let rulerView = LineNumberRulerView(textView: textView)
			scrollView.verticalRulerView = rulerView
			scrollView.hasVerticalRuler = true
			scrollView.rulersVisible = true
		}
		
		// Use a monospaced font
		let font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
		textView.font = font
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
	var dataController: DataController? {
		return DataController.shared
	}
	
	func prepareView() {
		prepareTextView()
		prepareTableView()
	}
	
	func prepareTextView() {
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
	
	func prepareTableView() {
		defer {
			tableView.reloadData()
		}
		tableView.tableColumns.forEach { tableView.removeTableColumn($0) }
		guard let parsedFile = parsedFile else { return }
		
		let header = parsedFile.header.first
		
		let columns: [NSTableColumn] = (0..<parsedFile.numberOfColumns).map { index in
			let column = NSTableColumn()
			let title: String? = {
				guard let header = header else { return nil }
				guard index < header.count else { return nil }
				return header[index]
			}()
			column.title = title ?? ""
			return column
		}
		
		columns.forEach { tableView.addTableColumn($0) }
	}
	
	func parseFile() -> ParsedFile? {
		guard let file = file else { return nil }
		guard let parser = dataController?.parser(for: file) else { return nil }
		return parser.parse(file: file)
	}
}
