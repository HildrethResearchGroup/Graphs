//
//  DataItemsContent.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct CenterContent: View {
    
    @Bindable var dataListVM: DataListViewModel
    var graphListVM: GraphControllerListViewModel
    
    
    init(_ dataListVM: DataListViewModel, _ graphListVM: GraphControllerListViewModel ) {
        self.dataListVM = dataListVM
        self.graphListVM = graphListVM
    }
    
    
    var body: some View {
        VSplitView {
            DataItemsTableView(dataListVM)
                .frame(minHeight: 300, maxHeight: .infinity)
            GraphListView(viewModel: graphListVM)
                .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: 1000)
        }
        .searchable(text: $dataListVM.filter, placement: .toolbar)
    }
}



/*
 // MARK: - Preview
 #Preview {
     CenterContent(DataListViewModel(DataController(withDelegate: nil), SelectionManager()))
 }
 */

