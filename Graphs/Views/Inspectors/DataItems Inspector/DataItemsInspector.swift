//
//  DataItemsInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsInspector: View {
    
    @Bindable var viewModel: DataItemsInspectorViewModel
    
    
    init(_ viewModel: DataItemsInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Form {
            TextField("Name:", text: $viewModel.name)
                .onSubmit { viewModel.updateNames() }
                //.disabled(viewModel.disableNameTextfield)
            
            HStack {
                Text("FilePath:")
                Text(viewModel.filePath)
                Spacer()
                Button("􀉣") {
                    
                }
                .disabled(viewModel.disableNameFilepath)
            }
        }.formStyle(.grouped)
        
    }
}

#Preview {
    DataItemsInspector(DataItemsInspectorViewModel(DataController(withDelegate: nil), SelectionManager()))
}
