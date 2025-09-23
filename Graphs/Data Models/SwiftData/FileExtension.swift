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
class FileExtension: Identifiable {
    var localID: LocalID
    
    var fileExtension: String = "ext"
    var userNotes: String = ""
    
    init() {
        localID = LocalID()
    }
    
    convenience init(_ fileExtension: String, _ userNotes: String) {
        self.init()
        
        self.fileExtension = fileExtension
        self.userNotes = userNotes
    }
    
    
    func contains(_ content: String) -> Bool {
        
        
        if fileExtension.lowercased().contains(content.lowercased()) { return true }
        else if userNotes.lowercased().contains(content.lowercased()) { return true }
        else { return false }
    }
    

    
    // MARK: - Default Extensions
    static var defaultExtensions: [FileExtension] {
        
        let txtOutput = FileExtension("txt", "Generic Text file")
        let csvOutput = FileExtension("cvs", "Comma Separated Values file")
        let tabOutput = FileExtension("tab", "Tab Separated Values file")
        
        return [txtOutput, csvOutput, tabOutput]
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
