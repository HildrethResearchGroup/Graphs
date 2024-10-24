//
//  DataItemsContent.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct CenterContent: View {
    
    @Bindable var dataListVM: DataListViewModel
    var graphListVM: GraphListViewModel
    
    
    init(_ dataListVM: DataListViewModel, _ graphListVM: GraphListViewModel ) {
        self.dataListVM = dataListVM
        self.graphListVM = graphListVM
    }
    
    
    var body: some View {
        VSplitView {
            DataItemsListView(dataListVM)
            GraphListView(viewModel: graphListVM)
        }
    }
}



/*
 // MARK: - Preview
 #Preview {
     CenterContent(DataListViewModel(DataController(withDelegate: nil), SelectionManager()))
 }
 */

