//
//  GraphControllerDataSource.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


protocol GraphControllerDataSource {
    func parsedFile(for dataItem: DataItem) async -> ParsedFile?
    func cachedGraphURL(for dataItem: DataItem) async -> URL?
}
