//
//  DataItemsListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsListView: View {
    @Bindable var viewModel: DataListViewModel
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.dataItems, id: \.id, selection: $viewModel.selection) { nextDataItem in
            Text(nextDataItem.name)
                .contextMenu {
                    deleteButton
                }
            
        }
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button("Delete") {
            viewModel.deleteSelectedDataItems()
        }
    }
}


// MARK: - Preview
/*
 #Preview {
     DataItemsListView()
 }
 */

