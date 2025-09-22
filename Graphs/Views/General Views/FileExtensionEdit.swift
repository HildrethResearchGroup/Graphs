//
//  SwiftDataTextfield.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/22/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct FileExtensionEdit: View {
    
    @Bindable var fileExtension: FileExtension
    
    init( _ fileExtension: FileExtension) {
        self.fileExtension = fileExtension
    }
    
    var body: some View {
        Form {
            TextField("Ext.", text: $fileExtension.fileExtension)
            TextField("Notes", text: $fileExtension.userNotes)
        }
    }
}

#Preview {
    FileExtensionEdit(FileExtension())
}
