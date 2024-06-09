//
//  URL_openFiles.swift
//  Images-LectureDevelopment
//
//  Created by Owen Hildreth on 4/6/24.
//

import Foundation

// ADD
import Cocoa

extension URL {
    /// Opens Finder and highlights the file at the url's path.
    func showInFinder() {
        NSWorkspace.shared
            .activateFileViewerSelecting([self])
    }
}

extension Collection where Element == URL {
    /// Opens Finder and highlights the files at the urls' paths.
    func showInFinder() {
        NSWorkspace.shared
            .activateFileViewerSelecting(map { $0 })
    }
}
