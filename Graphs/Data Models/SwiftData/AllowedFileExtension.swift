//
//  AllowedFileExtensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 2/28/24.
//

import Foundation


struct AllowedFileExtension: Identifiable, Codable, Hashable {
    // UPDATE
    var id = ID()
    
    var fileExtension: String = "Extension"
    var userNotes: String = ""
    
    // ADD
    struct ID: Identifiable, Codable, Hashable {
        var id = UUID()
    }
    
    static var defaultFileExtensions: [AllowedFileExtension] {
        return [
            .init(fileExtension: "txt"),
            .init(fileExtension: "csv"),
            .init(fileExtension: "tab")
        ]
    }
    
    func contains(_ content: String) -> Bool {
        if fileExtension.contains(content) {
            return true
        } else if userNotes.contains(content) {
            return true
        } else {
            return false
        }
    }
}
