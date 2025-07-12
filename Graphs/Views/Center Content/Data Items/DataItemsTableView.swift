//
//  DataItemsTableView.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/11/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct DataItemsTableView: View {
    
    @Bindable var viewModel: DataListViewModel
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Table(selection: $viewModel.selection,
              sortOrder: $viewModel.sort) {
            TableColumn("Name", value: \.name)
            TableColumn("Folder", value: \.nodeName)
            TableColumn("Folder Path", value: \.nodePath)
            TableColumn("File Size", value: \.fileSize) {
                Text($0.scaledFileSize)
            }
            TableColumn("Import Date", value: \.creationDate) {
                Text($0.creationDate.formatted(date: .numeric, time: .omitted))
            }
            TableColumn("Creation Date", value: \.creationDate) {
                Text($0.creationDate.formatted(date: .numeric, time: .omitted))
            }
            TableColumn("Modified Date", value: \.contentModificationDate) {
                Text($0.contentModificationDate.formatted(date: .numeric, time: .omitted))
            }
            TableColumn("Open in Finder", value: \.url.relativePath) { imageItem in
                Button(action: {
                    imageItem.url.showInFinder()
                },
                       label: {Image(systemName: "link")})
            }
        }
        rows: {
            ForEach(viewModel.dataItems) { dataItem in
                TableRow(dataItem)
                    .contextMenu {
                        Button("Delete") { viewModel.deleteSelectedDataItems() }
                            .disabled(viewModel.selection.count == 0)
                    }
                }
            }
    }

}

#Preview {
    @Previewable var dataListVM = DataListViewModel(DataController(withDelegate: nil), SelectionManager())
    DataItemsTableView(dataListVM)
}
