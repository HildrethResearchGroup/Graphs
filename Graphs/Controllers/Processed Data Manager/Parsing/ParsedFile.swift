//
//  ParsedFile.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/16/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

/// The parsed contents of a file.
struct ParsedFile: Sendable, Codable {
    
    var lastParsedDate: Date = .now
    
    var dataItemID: UUID
    
    /// A string made from the lines spanning the Data's Experimental Details or an empty string if the parser does not include any Experimental Details
    ///
    /// - Note: This section may contain newline characters.  This data is cached.
    var experimentDetails: String
    
    
    /// An array of header rows. Each row is made by seperating the input file by the header separator character set.
    ///
    /// - NOTE: This data is NOT cached.
    var header: [[String]]
    
    
    /// An array of data rows. Each row is made by seperating the input file by the data separator character set.
    ///
    /// - NOTE: This data is NOT cached.
    var data: [[String]]
    
    
    /// A string made from the lines spanning the input file's footer, or an empty string if the Data does not include a Footer.
    ///
    /// - Note: This section may contain newline characters.
    var footer: String
    
    
    /// The number of columns is included so that each row doesn't have to be checked for the maximum number of columns each time the number of columns is needed (which can be quite often)
    /// The number of columns in the parsed file.
    /// - NOTE: This data is cached.
    var numberOfColumns: Int
}
