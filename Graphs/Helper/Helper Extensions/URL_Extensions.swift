//
//  URL_Extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
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
        
        let fileExtension = self.pathExtension
        
        if fileExtension == URL.dataGraphFileExtension {
            return false
        }
        
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    
    /// Extension used for Parser Settings files
    static var parserSettingsFileExtension = "gparser"
    
    
    /// Extension used for DataGraph files
    static var dataGraphFileExtension = "dgraph"
    
    
    var urlType: URLType {
        return URLType(withURL: self)
    }
    
    
    /// Convience Enum of the type of URL
    ///
    /// - **file**: URL is a file
    /// - **directory**: URL is a directory
    /// - **fileDoesNotExist**: URL points to a file or directory that doesn't exist
    /// - **dgraph**: URL is a DataGraph file
    /// - **gparser**: URL is a Parser Settings file
    enum URLType {
        
        /// URL is a DataGraph file
        case dgraph
        
        /// URL is a Graphs Parser Settings File
        case gparser
        
        
        /// URL is a file
        case file
        
        /// URL is a directory
        case directory
        
        /// URL points to a file or directory that doesn't exist
        case fileOrDirectoryDoesNotExist
        
        
        
        init(withURL url: URL) {
            
            let fileExtension = url.pathExtension
            
            if fileExtension == URL.dataGraphFileExtension {
                self = .dgraph
                return
            } else if fileExtension == URL.parserSettingsFileExtension {
                self = .gparser
                return
            }
            
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
        
        let fm = FileManager.default
        
        //let testURL = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: .applicationSupportDirectory, create: true)
        
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
    
    
    var fileExists: Bool {
        let fm = FileManager.default
        
        return fm.fileExists(atPath: self.path(percentEncoded: false))
    }
    
    var truncatedPath: String {
        
        var localURL = self
        let pathExtension = localURL.pathExtension
        
        localURL = localURL.deletingPathExtension()
        
        var output = "." + pathExtension
        
        for index in 0...2 {
            let nextComponent = localURL.lastPathComponent
            
            if index == 0 {
                output = nextComponent + output
            } else {
                output = nextComponent + "/" + output
            }

            localURL = localURL.deletingLastPathComponent()
        }
        
        return "..." + output
        
    }
}
