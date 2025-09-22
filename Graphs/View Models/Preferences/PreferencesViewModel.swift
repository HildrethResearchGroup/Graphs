//
//  PreferencesController.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftUI


@Observable
@MainActor
class PreferencesViewModel {
    
    private var dataController: DataController
    
    var selection: FileExtension.ID? = nil
    
    var search: String = ""
    
    var sort: [KeyPathComparator<FileExtension>] = [.init(\.fileExtension)]
    
    
    // MARK: - File Extensions
    private var allFileExtensions: [FileExtension] { dataController.fileExtensions }
    
    
    private var sortedFileExtensions: [FileExtension] {
        return allFileExtensions.sorted(using: sort)
    }
    
    
    var filteredFileExtensions: [FileExtension] {
        if search.isEmpty {
            return sortedFileExtensions
        } else {
            return sortedFileExtensions.filter({ $0.contains(search) })
        }
    }
    
    
    var selectedFileExtension: FileExtension? {
        allFileExtensions.filter({ $0.id == selection}).first
    }
    
    
    // MARK: - Initializers
    init(_ dataController: DataController) {
        self.dataController = dataController
    }
    
    
    
    // MARK: - Creating and Deleting
    func addExtension() {
        dataController.createNewFileExtension()
    }
    
    func deleteSelectedFileExtensions() {
        guard let selectedFileExtension else { return }
        dataController.delete(selectedFileExtension)
    }
}


// MARK: - UI
extension PreferencesViewModel {
    var toolTip_DeleteSelectionButton: String {
        
        guard let selectedFileExtension else {
            return "Select File Extension to Delete"
        }
        
        return "Delete \(selectedFileExtension.fileExtension) File Extension"

    }
    
    var disabled_DeleteSelectionButton: Bool {
        return selection == nil
    }
}
