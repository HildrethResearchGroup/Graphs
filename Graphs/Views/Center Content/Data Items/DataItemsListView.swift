//
//  DataItemsListView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct DataItemsListView: View {
    @Bindable var viewModel: DataListViewModel
    
    @AppStorage("openLotsOfFinderItems") private var openLotsOfFinderItems = true
    @State private var shouldDisplayFinderWarning = false
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.dataItems, id: \.id, selection: $viewModel.selection) { nextDataItem in
            Text(nextDataItem.name)
                .contextMenu {
                    Button_Delete
                    Button_OpenInFinder(nextDataItem)
                }
            
        }
    }
    
    @ViewBuilder
    var Button_Delete: some View {
        Button("Delete") {
            viewModel.deleteSelectedDataItems()
        }
    }
    
    
    
    @ViewBuilder
    private func Button_OpenInFinder(_ dataItem: DataItem) -> some View {
        Button("Show in Finder") { openDataItemsInFinder(dataItem)}
        .alert("This will open \(viewModel.dataItems.count) Finder Windows.  Are you sure you want to do this?", isPresented: $shouldDisplayFinderWarning) {
            Button("Yes", role: .cancel) {viewModel.openInFinder(dataItem)}
            Button("No", role: .destructive) {}
        }
    }
    
    
    
    private func openDataItemsInFinder(_ dataItem: DataItem) {
        let count = viewModel.dataItems.count
        
        if openLotsOfFinderItems == true {
            viewModel.openInFinder(dataItem)
        } else {
            if count <= 10 {
                viewModel.openInFinder(dataItem)
            } else {
                self.shouldDisplayFinderWarning = true
            }
        }
    }

    
    
}


// MARK: - Preview
/*
 #Preview {
     DataItemsListView()
 }
 */

