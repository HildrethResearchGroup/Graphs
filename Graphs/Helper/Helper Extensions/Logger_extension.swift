//
//  Logger_extension.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import OSLog

//https://www.avanderlee.com/debugging/oslog-unified-logging/


extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the parsing errors
    static let parsing = Logger(subsystem: subsystem, category: "parsing")
    
    /// Logs Data Controller Errors
    ///
    ///Example Usage
    ///```swift
    /// Logger.dataController.info("DataController: Failed to Fetch ParserSettings")
    /// ```
    static let dataController = Logger(subsystem: subsystem, category: "dataController")
    
    /// Logs DataItem  Errors
    static let dataItem = Logger(subsystem: subsystem, category: "dataItem")
    
    /// Logs View Model Errors
    static let viewModel = Logger(subsystem: subsystem, category: "viewModel")
    
    /// Logs ProcessData Errors
    static let processingData = Logger(subsystem: subsystem, category: "processingData")
}
