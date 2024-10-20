//
//  DataController_Saving.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/15/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation

extension DataController {
    func saveParserSettings(_ parserSettings: ParserSettings, to url: URL) {
        do {
            try parserSettings.save(to: url)
        } catch  {
            print(error)
        }
    }
}
