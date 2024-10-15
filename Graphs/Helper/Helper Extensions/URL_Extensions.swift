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
    
    /// Convience property on the filename of the URL
    ///
    /// Returns either the name of the file or nil if the URL is a directory
    var fileName: String? {
        
        if self.pathExtension == "" {
            return nil
        } else {
            return self.deletingPathExtension().lastPathComponent
        }
    }
    
    /// Opens Finder and highlights the file at the url's path.
    func showInFinder() {
        NSWorkspace.shared
            .activateFileViewerSelecting([self])
    }
    
    
    /// Convience property stating if the URL is a directory
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    
    /// Extension used for Parser Settings files
    static var parserSettingsFileExtension = "gparser"
    
    
    /// Extension used for DataGraph files
    static var dataGraphFileExtension = "dgraph"
    
    
    
    /// Convience Enum of the type of URL
    ///
    /// - **file**: URL is a file
    /// - **directory**: URL is a directory
    /// - **fileDoesNotExist**: URL points to a file or directory that doesn't exist
    enum URLType {
        /// URL is a file
        case file
        
        /// URL is a directory
        case directory
        
        /// URL points to a file or directory that doesn't exist
        case fileOrDirectoryDoesNotExist
        
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
                self = .fileOrDirectoryDoesNotExist
                return
            }
        }
    }
    
    
    /// Database storage location for Graphs application
    static var swiftDataStorageLocation: URL {
        var location = URL.applicationSupportDirectory
        location.append(path: "Graphs/Data/GraphsDatabase.sqlite")
        
        return location
    }
    
    
    /// Storage Directory URL for Graphs application
    static var cacheStorageDirectory: URL {
        let location = URL.applicationSupportDirectory
        return location.appending(path: "Graphs/Cached/")
    }
    
    
    /// Storage Directory URL for Processed Data Cache
    ///
    /// Uses the URL.cacheStorageDirectory as the base URL
    static var cachedProcessedDataDirectory: URL {
        let location = URL.cacheStorageDirectory
        
        return location.appending(path: "Processed Data/")
    }
    
    
    /// Storage Directory URL for Graphs Cache
    ///
    /// Uses the URL.cacheStorageDirectory as the base URL
    static var cachedGraphedDataDirectory: URL {
        let location = URL.cacheStorageDirectory
        return location.appending(path: "Processed Graphs/")
    }
    
    
    /// Date that the URL was last modified
    var dateLastModified: Date? {
        let resourceValues = try? self.resourceValues(forKeys: [.contentModificationDateKey])
        
        return resourceValues?.contentModificationDate
    }
}
