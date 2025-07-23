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
    
    @State private var sort: [KeyPathComparator<DataItem>] = [.init(\.name), .init(\.nodePath)]
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            //Table(selection: $viewModel.selection, sortOrder: $viewModel.sort) {
            Table(selection: $viewModel.selection, sortOrder: $viewModel.sort) {
                TableColumn("Name", value: \.name) {
                    Text($0.name)
                        .help($0.url.path(percentEncoded: false))
                }
                TableColumn("Folder", value: \.nodeName)
                TableColumn("Folder Path", value: \.nodePath) {
                    Text($0.nodePath)
                        .help($0.nodePath)
                }
                TableColumn("File Size", value: \.fileSize) {
                    Text($0.scaledFileSize)
                }
                .alignment(.center)
                TableColumn("Import Date", value: \.creationDate) {
                    Text($0.creationDate.formatted(date: .numeric, time: .omitted))
                }
                .alignment(.center)
                TableColumn("Creation Date", value: \.creationDate) {
                    Text($0.creationDate.formatted(date: .numeric, time: .omitted))
                }
                .alignment(.center)
                TableColumn("Modified Date", value: \.contentModificationDate) {
                    Text($0.contentModificationDate.formatted(date: .numeric, time: .omitted))
                    
                }
                .alignment(.center)
                TableColumn("Open in Finder", value: \.url.relativePath) { nextDataItem in
                    Button(action: {
                        nextDataItem.url.showInFinder()
                    },
                           label: {
                        Image(systemName: "link")
                            .foregroundStyle(viewModel.foregroundColor(for: nextDataItem))
                            .help("Show in Finder:\n\(nextDataItem.truncatedFilePath)")
                    })
                }
                .alignment(.center)
            }
            rows: {
                ForEach(viewModel.dataItems, id: \.localID) { dataItem in
                    TableRow(dataItem)
                        .contextMenu {
                            Button("Delete") { viewModel.deleteSelectedDataItems() }
                                .disabled(viewModel.selection.count == 0)
                        }
                    }
                } // END: Table
        } // END: VStack
    }

}

#Preview {
    @Previewable var dataListVM = DataListViewModel(DataController(withDelegate: nil), SelectionManager())
    DataItemsTableView(dataListVM)
}
