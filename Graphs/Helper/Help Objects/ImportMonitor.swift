//
//  ImportMonitor.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/15/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftUI


@MainActor
class ImportMonitor {
    static var shared: ImportMonitor = ImportMonitor()
    
    
    /// UserDefault storage on if the users wasn't to be prompted when importing a Data Graph file as a Template
    @AppStorage(UserDefaults.neverAskBeforeImportingDataGraphFilesAsTemplate) private var neverAskBeforeImportingDataGraphFilesAsTemplate: Bool = false
    
    /// UserDefault storage on the default behavior for importating Data Graph files
    @AppStorage(UserDefaults.shouldAlwaysImportDataGraphFilesAsTemplate) private var shouldAlwaysImportDataGraphFilesAsTemplate: Bool = true
    
    private var shouldImportDataGraphFileAsTemplateForThisImport = true
    
    private var hasShownImportQuestionForThisImport: Bool = false
    
    private var shouldShowImportQuestionForThisImport: Bool = true
    
    private var importState: ImportState = .idle {
        didSet {
            if importState == .idle {
                resetState()
            }
        }
    }
    
   
    
   
    
    private func resetState() {
        hasShownImportQuestionForThisImport = true
        shouldShowImportQuestionForThisImport = false
    }
    
    
    private init() {
        
    }
    
    func importStarting() {
        importState = .inProgress
    }
    
    func importComplete() {
        importState = .idle
    }
    
    private func shouldShowImportQuestion() -> Bool {
        
        // User has checked not to ask about importing DataGraph files anymore
        if neverAskBeforeImportingDataGraphFilesAsTemplate == true {
            return false
        }
        
        if hasShownImportQuestionForThisImport {
            return false
        }
        
        return shouldShowImportQuestionForThisImport
    }
    
    
    func shouldImportdgraphFileAsGraphTemplate() -> Bool {
        
        if shouldShowImportQuestion() == false {
            
            if shouldAlwaysImportDataGraphFilesAsTemplate == false {
                return false
            }
            
            return shouldImportDataGraphFileAsTemplateForThisImport
        }
        
        
        
        if !hasShownImportQuestionForThisImport { hasShownImportQuestionForThisImport = true }
        
        let alert = NSAlert()
        alert.messageText = "Importing .dgraph file"
        alert.informativeText = "For this Importing Session: Should this file be imported as a Graph Template and then ask again?  Do you want any remaining dgraph files also imported as a Graph Template?  Should all dgraph files be skipped and not imported?"
        alert.showsSuppressionButton = true
        
        switch neverAskBeforeImportingDataGraphFilesAsTemplate {
        case true: alert.suppressionButton?.state = .on
        case false: alert.suppressionButton?.state = .off
        }
        alert.suppressionButton?.title = "Never ask again"
        alert.addButton(withTitle: "Import this dgraph as Template")
        alert.addButton(withTitle: "Import remainin dgraph files as Template")
        alert.addButton(withTitle: "Don't import dgraph files")
        
        
        let response = alert.runModal()
        
        
        
        if let suppressionButton = alert.suppressionButton {
            if suppressionButton.state == .on {
                neverAskBeforeImportingDataGraphFilesAsTemplate = true
            } else {
                neverAskBeforeImportingDataGraphFilesAsTemplate = false
            }
        }
        
        switch response {
        case .alertFirstButtonReturn:
            print("First button = \(response)")
            shouldImportDataGraphFileAsTemplateForThisImport = true
            return true
        case .alertSecondButtonReturn:
            print("Second button = \(response)")
            shouldShowImportQuestionForThisImport = false
            return true
        case .alertThirdButtonReturn:
            print("Third button = \(response)")
            shouldShowImportQuestionForThisImport = false
            return false
        default:
            print("default for: \(response)")
            return false
        }

    }
    
    
    func setNeverAskBeforeImportingDataGraphFilesAsTemplate(_ neverAsk: Bool) {
        self.neverAskBeforeImportingDataGraphFilesAsTemplate = neverAsk
    }
    
    
    
    enum ImportState: String, Identifiable, Hashable, Codable {
        var id: Self { self }
        case idle
        case inProgress
    }
    
}
