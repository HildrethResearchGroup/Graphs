//
//  URL_Extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/6/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation


extension URL {
    var fileName: String { self.deletingPathExtension().lastPathComponent }
    
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
}
