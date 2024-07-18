//
//  DataItemsListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsListView: View {
    var dataItems: [DataItem]
    
    @State var selection: DataItem
    
    var body: some View {
        List(dataItems) { nextDataItem in
            Text(nextDataItem.name)
        }
    }
}

/*
 #Preview {
     DataItemsListView()
 }
 */

