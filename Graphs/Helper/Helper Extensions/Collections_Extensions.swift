//
//  Collections_Extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


extension Collection where Element == URL {
    /// Opens Finder and highlights the files at the urls' paths.
    func showInFinder() {
        NSWorkspace.shared
            .activateFileViewerSelecting(map { $0 })
    }
}
