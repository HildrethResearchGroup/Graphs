//
//  StringEncoding.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

extension String {
	/// Returns a string filled with the textual data of the file at the given url, and the detected encoding of the file.
	/// - Parameter url: The url of the file to read.
	/// - Throws: An error if the file could not be read.
	/// - Returns: A string from the textual data of the file, and the detected encoding.
	static func detectingEncoding(ofContents url: URL) throws -> (string: String, encoding: String.Encoding) {
		let data = try Data(contentsOf: url)
		// The resulting string for NSString.stringEncoding(for:encodingOptions:convertedString:usedLossyConversion:) is returned by a pointer argument. (Boo ObjC)
		var result: NSString?
		// NSString.stringEncoding(for:encodingOptions:convertedString:usedLossyConversion:) takes a dictionary of options -- include the .likelyLanguageKey for the user's Locale, so that the encoding can be guess more precisley.
		let options = [StringEncodingDetectionOptionsKey.likelyLanguageKey: Locale.current.languageCode ?? "en"]
		let encoding = NSString.stringEncoding(for: data,
																					 encodingOptions: options,
																					 convertedString: &result,
																					 usedLossyConversion: nil)
		if let result = result {
			let encoding = String.Encoding(rawValue: encoding)
			return (string: result as String, encoding: encoding)
		} else {
			// If the string couldn't be created using the guessed encoding, throw the cocoa text encoding couldn't be determined error.
			throw NSError(domain: NSCocoaErrorDomain, code: 264, userInfo: [:])
		}
	}
}
