//
//  DataItemsContent.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsContent: View {
    
    @Bindable var viewModel: DataListViewModel
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        VSplitView {
            DataItemsListView(viewModel)
            Text("Graphs")
        }
    }
}


// MARK: - Preview
#Preview {
    DataItemsContent(DataListViewModel(DataController(withDelegate: nil), SelectionManager()))
}
