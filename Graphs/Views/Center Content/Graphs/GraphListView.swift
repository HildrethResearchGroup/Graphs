//
//  GraphListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/22/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct GraphListView: View {
    
    @Bindable var viewModel: GraphControllerListViewModel
    
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack {
                if viewModel.processedData.count != 0 {
                    ForEach(viewModel.processedData, id: \.id) { nextData in
                        VStack {
                            Text(nextData.dataItem.name)
                            GraphViewRepresentable(graphController: nextData.graphController)
                                .aspectRatio(1.3, contentMode: .fit)
                        }
                    }
                } else {
                    HStack {
                        Text("Select Data")
                    }
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

