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
        }
    }
}


// MARK: - Preview
/*
 #Preview {
     DataItemsListView()
 }
 */

