//
//  GraphListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/22/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct GraphListView: View {
    
    @Bindable var viewModel: GraphControllerListViewModel
    
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center) {
                if viewModel.processedData.count != 0 {
                    ForEach(viewModel.processedData, id: \.id) { nextData in
                        GraphViewRepresentable(graphController: nextData.graphController)
                            .aspectRatio(1.4, contentMode: .fit)
                    }
                } else {
                    EmptyView()
                }
            }
            
        }
    }
}



/*
 #Preview {
     GraphListView()
 }
 */

