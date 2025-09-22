//
//  GraphsApp.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/4/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct GraphsApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State var appController = AppController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appController)
        }
        .environment(appController)
        .commands{
            ExportMenuCommands
            DeleteMenuCommands
            ImportMenuCommands
            PasteBoardCommands
            UndoRedoCommands
        }
        
        Settings {
            Preferences(appController.preferencesVM)
        }
    }
    
    
    
}

// MARK: - Toolbar Commands
extension GraphsApp {
    
    fileprivate var menuVM: MenuViewModel {
        appController.menuViewModel
    }
    
    
    // MARK: - Importing
    fileprivate var ImportMenuCommands: some Commands {
        CommandGroup(after: .newItem) {
            Button_newNode
            Menu("Import") {
                Button_importAll
                Button_importDataFiles
                Button_importGraphTemplate
                Button_importParserSettings
            }
        }
    }
    
    private var Button_newNode: some View {
        Button("New Folder", action: menuVM.newFolder)
            .help(menuVM.toolTip_newFolder)
    }
    
    private var Button_importAll: some View {
        Button("All...", action: menuVM.importAll)
            .disabled(menuVM.isDisabled_importAll)
            .help(menuVM.toolTip_importAll)
    }
    
    private var Button_importDataFiles: some View {
        Button("Data Files...", action: menuVM.importDataFiles)
            .disabled(menuVM.isDisabled_importDataFiles)
            .help(menuVM.toolTip_importDataFiles)
    }
    
    
    private var Button_importGraphTemplate: some View {
        Button("Graph Template...", action: menuVM.importGraphTemplate)
            .disabled(menuVM.isDisabled_importGraphTemplate)
            .help(menuVM.toolTip_importGraphTemplate)
    }
    
    
    private var Button_importParserSettings: some View {
        Button("Parser Settings...", action: menuVM.importParserSettings)
            .disabled(menuVM.isDisabled_importParserSettings)
            .help(menuVM.toolTip_importParserSettings)
    }
    
    
    // MARK: Exporting
    fileprivate var ExportMenuCommands: some Commands {
        CommandGroup(after: .newItem) {
            Menu("Export") {
                Button_exportDataAsGraphTemplate
                Button_exportParserSettings
            }
        }
    }
    
    private var Button_exportDataAsGraphTemplate: some View {
        Button("Export Data as Graphs", action: menuVM.exportGraphsFromSelectedDataItems)
            .disabled(menuVM.isDisabled_exportGraphsFromSelectedDataItems)
            .help(menuVM.toolTip_exportGraphsFromSelectedDataItems)
    }
    
    private var Button_exportParserSettings: some View {
        Button("Export Parser", action: menuVM.exportSelectedParserSettings)
            .disabled(menuVM.isDisabled_exportSelectedParserSettings)
            .help(menuVM.toolTip_exportSelectedParserSettings)
    }
    
    
    
    // MARK: Deletion
    fileprivate var DeleteMenuCommands: some Commands {
        CommandGroup(replacing: .textEditing) {
            Menu("Delete") {
                Button_deleteDataItems
                Button_deleteNodes
                Button_deleteGraphTemplate
                Button_deleteParserSettings
            }
        }
    }
    
    
    private var Button_deleteDataItems: some View {
        Button("Data", action: menuVM.deleteSelectedDataItems)
            .disabled(menuVM.isDisabled_deleteSelectedDataItem)
            .help(menuVM.toolTip_deleteSelectedDataItem)
    }
    
    
    private var Button_deleteNodes: some View {
        Button("Folders", action: menuVM.deleteSelectedNodes)
            .disabled(menuVM.isDisabled_deleteSelectedNodes)
            .help(menuVM.toolTip_deleteSelectedNodes)
    }
    
    
    private var Button_deleteGraphTemplate: some View {
        Button("Graph Template", action: menuVM.deleteSelectedGraphTemplate)
            .disabled(menuVM.isDisabled_deleteSelectedGraphTemplate)
            .help(menuVM.toolTip_deleteSelectedGraphTemplate)
    }
    
    
    private var Button_deleteParserSettings: some View {
        Button("Parser", action: menuVM.deleteSelectedParserSettings)
            .disabled(menuVM.isDisabled_deleteSelectedParserSettings)
            .help(menuVM.toolTip_deleteSelectedParserSettings)
    }
    
 
    
    // MARK: - Commands to Remove
    private var PasteBoardCommands: some Commands {
        CommandGroup(replacing: .pasteboard, addition: {})
    }
    
    private var UndoRedoCommands: some Commands {
        CommandGroup(replacing: .undoRedo, addition: {})
    }
}
