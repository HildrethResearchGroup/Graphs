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
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(parserSettings)
            try data.write(to: url)
        } catch  {
            print(error)
        }
    }
}
