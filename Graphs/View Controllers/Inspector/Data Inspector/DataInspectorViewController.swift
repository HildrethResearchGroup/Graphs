//
//  DataInspectorViewController.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Cocoa

/// A view controller which manages the data inspector.
class DataInspectorViewController: NSViewController {
	/// The display type segmented control.
	@IBOutlet weak var tabSegmentedControl: NSSegmentedControl!
	/// The tab view that displays either a text view or table view.
	@IBOutlet weak var tabView: NSTabView!
	/// The text view which shows the file's contents.
	@IBOutlet var textView: LineNumberedTextView!
	/// The table view which shows the file's parsed contents.
	@IBOutlet weak var tableView: NSTableView!
	/// A label which is displayed if there is an error parsing the file.
	@IBOutlet weak var errorLabel: NSTextField!
	/// The file that the controller is dispalying the contents of.
	var file: File? {
		didSet {
			// TODO: This needs to be called when the parser changes
            parseFile() {
                result in
                self.parsedFile = result
                self.prepareView()
            }
		}
	}
	/// The parsed file.
	var parsedFile: ParsedFile?
	/// Called when the segmented control has a new button selected.
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
}

// MARK: Helpers
extension DataInspectorViewController {
	/// The application's data controller.
	var dataController: DataController? {
		return DataController.shared
	}
	/// Prepares the view for a new file or parser.
	func prepareView() {
		prepareTextView()
		prepareTableView()
	}
	/// Prepares the text view for a new file.
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
	/// Prepares the table view for a new file.
	func prepareTableView() {
		defer {
			tableView.reloadData()
		}
		// Remove all columns
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
		// Add a column for each column that needs to be parsed.
		columns.forEach { tableView.addTableColumn($0) }
	}
	/// Parses the currently displayed file.
    func parseFile(completion:@escaping((ParsedFile?) -> Void)) {
		guard let file = file else {
            completion(nil)
            return
        }
		guard let parser = dataController?.parser(for: file) else {
            completion(nil)
            return
        }
        parser.parse(file: file) { result in
            completion(result)
        }
	}
}
