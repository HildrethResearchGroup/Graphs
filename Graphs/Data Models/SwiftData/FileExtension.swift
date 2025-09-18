//
//  FileExtension.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/18/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class FileExtension {
    var localID: LocalID
    
    var fileExtension: String = "Ext"
    var userNotes: String = ""
    
    init() {
        localID = LocalID()
    }
    
    
}


extension FileExtension: SelectableCheck {
    struct LocalID: SelectableID, Transferable {
        
        var id = UUID()
        
        var uuidString: String {
            id.uuidString
        }
        
        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .uuid)
                ProxyRepresentation(exporting: \.id)
            }
    }
    
    func matches(_ uuid: UUID) -> Bool {
        return localID.id == uuid
    }
}
