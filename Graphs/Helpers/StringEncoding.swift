//
//  StringEncoding.swift
//  Graphs
//
//  Created by Connor Barnes on 7/14/20.
//  Copyright © 2020 Connor Barnes. All rights reserved.
//

import Foundation

extension String {
	static func detectingEncoding(ofContents url: URL) throws -> (string: String, encoding: String.Encoding) {
		let data = try Data(contentsOf: url)
		var result: NSString?
		let options = [StringEncodingDetectionOptionsKey.likelyLanguageKey: Locale.current.languageCode ?? "en"]
		let encoding = NSString.stringEncoding(for: data,
																					 encodingOptions: options,
																					 convertedString: &result,
																					 usedLossyConversion: nil)
		if let result = result {
			let encoding = String.Encoding(rawValue: encoding)
			return (string: result as String, encoding: encoding)
		} else {
			throw NSError(domain: NSCocoaErrorDomain, code: 264, userInfo: [:])
		}
	}
}
