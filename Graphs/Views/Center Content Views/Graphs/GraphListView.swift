//
//  GraphListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 10/22/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct GraphListView: View {
    
    var viewModel: GraphListViewModel
    
    
    var body: some View {
        ScrollView(.horizontal) {
            
            LazyHStack {
                ForEach(viewModel.processedData) { nextData in
                    if let graphViewController = nextData.graphController {
                        GraphViewRepresentable(graphController: graphViewController)
                    }
                }
                
                /*
                 ForEach(viewModel.processedData, id: \.id) { nextItem in
                     if let image = NSImage(contentsOf: nextItem.url) {
                         Image(nsImage: image)
                             .resizable()
                             .scaledToFill()
                     } else {
                         Text("\(nextItem.name) could not be found")
                     }
                 }
                 */
                
            }
        }
        .frame(minHeight: 300, maxHeight: .infinity)    }
}



/*
 #Preview {
     GraphListView()
 }
 */

