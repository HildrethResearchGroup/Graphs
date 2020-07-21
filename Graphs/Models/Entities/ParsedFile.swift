//
//  ParsedFile.swift
//  Graphs
//
//  Created by Connor Barnes on 7/16/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

/// The parsed contents of a file.
struct ParsedFile {
	/// A string made from the lines spanning the parser's experiment details paramaters, or an empty string if the parser does not include experimental details.
	///
	/// - Note: This section may contain newline characters.
	var experimentDetails: String
	/// An array of header rows. Each row is made by seperating the row string by the header separator character set.
	var header: [[String]]
	/// An array of data rows. Each row is made by seperating the row string by the data separator character set.
	var data: [[String]]
	// The number of columns is included so that each row doesn't have to be checked for the maximum number of columns each time the number of columns is needed (which can be quite often)
	/// The number of columns in the parsed file.
	var numberOfColumns: Int
}
