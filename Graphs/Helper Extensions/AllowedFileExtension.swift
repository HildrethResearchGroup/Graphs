//
//  AllowedFileExtensions.swift
//  Images-LectureDevelopment
//
//  Created by Owen Hildreth on 2/28/24.
//

import Foundation

struct AllowedFileExtension: Identifiable, Codable, Hashable {
    // UPDATE
    var id = ID()
    
    var fileExtension: String = "Extension"
    
    // ADD
    struct ID: Identifiable, Codable, Hashable {
        var id = UUID()
    }
}
