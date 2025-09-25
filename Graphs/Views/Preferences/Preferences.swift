//
//  Preferences.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct Preferences: View {
    @Bindable var viewModel: PreferencesViewModel
    
    @AppStorage("preferencesFileExtensionTableCustomization") var customization: TableColumnCustomization<FileExtension>
    
    private var nilSelectionFileExtension = ""
    private var nilSelectionUserNotes = ""
    
    

    init(_ controller: PreferencesViewModel) {
        self.viewModel = controller
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            Table(of: FileExtension.self, selection: $viewModel.selection, sortOrder: $viewModel.sort, columnCustomization: $customization) {
                TableColumn("Ext.", value: \.fileExtension)
                    .customizationID("preferencesTable_fileExtension")
                TableColumn("User Notes", value: \.userNotes)
                    .customizationID("preferencesTable_userNotes")
            } rows : {
                ForEach(viewModel.filteredFileExtensions, id: \.localID) { //nextExtension in
                    
                    TableRow($0)
                        .contextMenu {
                        Button("Add New Extension", action: addNewFileExtension)
                        Button("Delete", action: deleteSelection)
                        }
                }
            }
            .alternatingRowBackgrounds(.disabled)
            .background { Color.white.ignoresSafeArea() }
            .frame(maxWidth: .infinity)
            .searchable(text: $viewModel.search, placement: .toolbarPrincipal)
            .navigationTitle("Import Extensions")
            .toolbar() {
                Button("", systemImage: "plus", action: addNewFileExtension)
                    .help("Add new File Extension")
                    .buttonStyle(.borderless)
                Button("", systemImage: "minus", action: deleteSelection)
                    .help(viewModel.toolTip_DeleteSelectionButton)
                    .buttonStyle(.borderless)
                    .disabled(viewModel.disabled_DeleteSelectionButton)
            }
            
            
            if let fileExtension = viewModel.selectedFileExtension {
                FileExtensionEdit(fileExtension)
                    .padding()
            } else {
                NilFileExtensionEdit
                    .padding()
            }
        }
    }
    
    
    private func deleteSelection() {
        viewModel.deleteSelectedFileExtensions()
    }
    
    private func addNewFileExtension() {
        viewModel.addExtension()
    }
    
    
    
    // MARK: - Nil Selection View
    @State private var nilExtension: String = ""
    
    @ViewBuilder
    private var NilFileExtensionEdit: some View {
        Form {
            NilTextField("Ext.")
            NilTextField("Notes")
        }
    }
    
}






// MARK: - Preview
#Preview {
    @Previewable
    @State var appController = AppController()
    
    Preferences(appController.preferencesVM)
}
