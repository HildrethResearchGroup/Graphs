//
//  String_pluralize.swift
//  Graphs
//
//  Created by Owen Hildreth on 3/24/24.
//

import Foundation

// https://stackoverflow.com/questions/77009572/localizing-plurals-when-the-number-is-not-included-in-the-text
extension String {
    /// Returns a pluralized version of the string based on the provided count.
    /// The function uses localized strings with inflection to correctly handle pluralization.
    /// - Parameter count: The quantity that determines the pluralization of the string.
    /// - Returns: A pluralized string that is correctly inflected for the given count.
    func pluralize(_ count: Int) -> String {
        // Create an AttributedString that is localized and can inflect based on the count.
        var attributed = AttributedString(localized: "^[\\(count) \\(self)](inflect: true)")
        
        // Find the range of the count within the attributed string.
        guard let range = attributed.range(of: "\\(count) ") else {
            return self
        }
        
        // Remove the count from the attributed string to only return the pluralized word.
        attributed.removeSubrange(range)
        
        // Convert the AttributedString back to a regular String and return it.
        return String(attributed.characters)
    }
}

