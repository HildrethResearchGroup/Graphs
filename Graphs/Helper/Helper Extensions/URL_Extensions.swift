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
    
    static var parserSettingsFileExtension = "gparser"
    
    static var dataGraphFileExtension = "dgraph"
    
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
    
    
    static var cacheStorageDirectory: URL {
        let location = URL.applicationSupportDirectory
        return location.appending(path: "Graphs/Cached/")
    }
    
    
    static var cachedProcessedDataDirectory: URL {
        let location = URL.cacheStorageDirectory
        
        return location.appending(path: "Processed Data/")
    }
    
    
    static var cachedGraphedDataDirectory: URL {
        let location = URL.cacheStorageDirectory
        return location.appending(path: "Processed Graphs/")
    }
    
    var dateLastModified: Date? {
        let resourceValues = try? self.resourceValues(forKeys: [.contentModificationDateKey])
        
        return resourceValues?.contentModificationDate
    }
}
