//
//  PreferencesController.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


@Observable
class PreferencesController {
    var allowedDataFileExtensions: [AllowedFileExtension] {
        didSet { save()  }
    }
    
    
    init() {
        let fileExtensionStrings = UserDefaults.standard.value(forKey: UserDefaults.allowedDataFileExtensions) as? [String] ?? []

        self.allowedDataFileExtensions = []
        
        self.allowedDataFileExtensions = extensions(fromStrings: fileExtensionStrings).sorted(by: {$0.fileExtension < $1.fileExtension})
    }
    
    
    func addExtension() {
        let newExtension = AllowedFileExtension()
        allowedDataFileExtensions.append(newExtension)
    }
    
    func removeExtension(_ fileExtensions: [AllowedFileExtension]) {
        for nextExtension in fileExtensions {
            self.allowedDataFileExtensions.removeAll(where: { $0 == nextExtension })
        }
        
    }
    
    
    func save() {
        let extensionsToSave = self.extensionStrings( self.allowedDataFileExtensions)
        UserDefaults.standard.setValue(extensionsToSave, forKey: UserDefaults.allowedDataFileExtensions)
    }
    
    
    private func extensions(fromStrings strings: [String]) -> [AllowedFileExtension] {
        var allowedExtensions: [AllowedFileExtension] = []
        
        for nextString in strings {
            let nextExtension = AllowedFileExtension(fileExtension: nextString)
            allowedExtensions.append(nextExtension)
        }
        
        return allowedExtensions
    }
    
    
    private func extensionStrings(_ extensions: [AllowedFileExtension]) -> [String] {
        var output: [String] = []
        
        for nextExtension in extensions {
            output.append(nextExtension.fileExtension)
        }
        
        return output
    }
}
