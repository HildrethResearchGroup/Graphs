//
//  String_newLineCharacter.swift
//  LineNumbers
//
//  Created by Owen Hildreth on 6/28/24.
//

import Foundation


extension String {
    func numberOfLines(_ newLineType: NewLineType?) throws -> Int {
        
        if self.count == 0 {
            return 0
        }
        
        guard let newLineType else {
            throw NumberOfLinesError.noLineSepatorProvided
        }
        
        let numberOfLines = self.split(separator: newLineType.stringLiteral).count
        
        if numberOfLines == 0 {
            throw NumberOfLinesError.newLineSeparatorNotFound
        } else {
            return numberOfLines
        }
    }
    
    enum NumberOfLinesError: Error {
        case noLineSepatorProvided
        case newLineSeparatorNotFound
    }
}




