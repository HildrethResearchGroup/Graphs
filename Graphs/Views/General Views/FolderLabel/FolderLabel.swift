//
//  FolderLabel.swift
//  Graphs
//
//  Created by Owen Hildreth on 2/5/26.
//  Copyright © 2026 Connor Barnes. All rights reserved.
//

import SwiftUI

struct FolderLabel: View {
    var isSelected: Bool
    
    init(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    var body: some View {
        if isSelected {
            Image(systemName: "folder.fill")
        } else {
            Image(systemName: "folder")
        }
    }
}


#Preview {
    FolderLabel(true)
        .padding()
    FolderLabel(false)
        .padding()
}
