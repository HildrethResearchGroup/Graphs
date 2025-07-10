//
//  ParserError.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation


enum ParserError: Error {
    case noParseSettings
    
    case indexBelowZero
    
    case startingIndexHigherThanEndingIndex
    
    case separatorIsNone
    
    case noExperimentalDetailsSeparator
    
    case noHeaderSeparator
    
    case noDataSeparator
    
    case couldNotGetStringFromURL
    
    }
