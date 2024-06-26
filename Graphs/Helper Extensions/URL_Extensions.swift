//
//  URL_Extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import Cocoa


extension URL {
    var fileName: String { self.deletingPathExtension().lastPathComponent }
    
    /// Opens Finder and highlights the file at the url's path.
    func showInFinder() {
        NSWorkspace.shared
            .activateFileViewerSelecting([self])
    }
    
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    enum URLType {
        case file
        case directory
        case fileDoesNotExist
        
        init(withURL url: URL) {
            
            if url.isDirectory {
                self = .directory
                return
            }
            
            let fm = FileManager()
            if fm.fileExists(atPath: url.path) {
                self = .file
                return
            } else {
                self = .fileDoesNotExist
                return
            }
        }
    }
    
    static var swiftDataStorageLocation: URL {
        var location = URL.applicationSupportDirectory
        location.append(path: "Graphs/Data/GraphsDatabase.sqlite")
        
        return location
    }
}
