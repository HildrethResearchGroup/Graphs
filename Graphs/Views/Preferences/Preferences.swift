//
//  Preferences.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct Preferences: View {
    // Using @State instead of @StateObject because the PreferencesController is using the @Observable macro, which eliminates the use of @StateObject and replaces it with just @State
    @State var preferencesController = PreferencesController()
    
    
    @State var selection: Set<AllowedFileExtension.ID> = []
    
    var body: some View {
        
        VStack(alignment: .center) {
            ExtensionsHeader
                
            
            List($preferencesController.allowedDataFileExtensions,
                 id: \.id,
                 editActions: [.delete, .move],
                 selection: $selection) { $nextExtension in
                TextField("", text: $nextExtension.fileExtension)
                    .onSubmit {
                        self.preferencesController.save()
                    }
                .contextMenu {
                    Button("Add New Extension", action: addNewFileExtension)
                    Button("Delete", action: deleteSelection)
                }
                .frame(width: 100, alignment: .center)
            }
        }
        .background {
            Color.white
                .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func deleteSelection() {
        let selectionArray = Array(selection)
        let extensionsToDelete = preferencesController.allowedDataFileExtensions.filter({selectionArray.contains($0.id)})
        
        preferencesController.removeExtension(extensionsToDelete)
    }
    
    private func addNewFileExtension() {
        preferencesController.addExtension()
    }
    
    private var ExtensionsHeader: some View {
        ZStack {
            HStack {
                Spacer()
                Text("Import Extensions")
                    .font(.title2)
                    .help("Lists allowed file extensions.  If your files aren't importing, check to make sure their file extension is on this list.  Note, file extensions are case-insenstive.")
                Spacer()
            }
            HStack {
                Spacer()
                Button("", systemImage: "plus", action: addNewFileExtension)
                    .help("Add new File Extension")
                    .buttonStyle(.plain)
                Button("", systemImage: "minus", action: deleteSelection)
                    .help( selection.count == 0 ? "Select File Extensions to Delete" : "Delete \(selection.count) File Extensions")
                    .buttonStyle(.plain)
                    .disabled(selection.count == 0)

            }
        }
    }
    
}


// MARK: - Preview
#Preview {
    Preferences()
}
