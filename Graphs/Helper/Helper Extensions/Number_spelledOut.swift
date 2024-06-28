//
//  Number_spelledOut.swift
//  Graphs
//
//  Created by Owen Hildreth on 3/24/24.
//

import Foundation

// https://stackoverflow.com/questions/66112863/how-to-convert-number-to-words-in-swift-by-using-func

extension NumberFormatter {
    static let spelled: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
}


extension Numeric {
    var spelledOut: String? { NumberFormatter.spelled.string(for: self) }
}
