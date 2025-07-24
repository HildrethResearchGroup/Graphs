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
    
    @AppStorage("dataItemTableCustomization") var customization: TableColumnCustomization<DataItem>
    
    init(_ viewModel: DataListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Table(selection: $viewModel.selection, sortOrder: $viewModel.sort, columnCustomization: $customization) {
            TableColumn("Name", value: \.name) {
                Text($0.name)
                    .help($0.url.path(percentEncoded: false))
            }
            .customizationID("name")

             TableColumn("Folder", value: \.nodeName)
                .customizationID("nodeName")
            
             TableColumn("Folder Path", value: \.nodePath) {
                 Text($0.nodePath)
                     .help($0.nodePath)
             }
             .customizationID("nodePath")
            
             TableColumn("File Size", value: \.fileSize) {
                 Text($0.scaledFileSize)
             }
             .alignment(.center)
             .customizationID("fileSize")
            
             TableColumn("Import Date", value: \.creationDate) {
                 Text($0.creationDate.formatted(date: .numeric, time: .omitted))
             }
             .alignment(.center)
             .customizationID("creationDate")
            
            TableColumn("Creation Date", value: \.contentCreationDate) {
                 Text($0.creationDate.formatted(date: .numeric, time: .omitted))
             }
             .alignment(.center)
             .customizationID("contentCreationDate")
            
            
             TableColumn("Modified Date", value: \.contentModificationDate) {
                 Text($0.contentModificationDate.formatted(date: .numeric, time: .omitted))
                 
             }
             .alignment(.center)
             .customizationID("contentModificationDate")
            
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
            ForEach(viewModel.dataItems, id: \.id) { dataItem in
                TableRow(dataItem)
                    .contextMenu {
                        Button_Delete
                        Button_Export
                    }
                }
            } // END: Table
    }
    
    
// MARK: - Buttons
    private var Button_Delete: some View {
        Button("Delete") { viewModel.deleteSelectedDataItems() }
            .disabled(viewModel.selection.count == 0)
    }
    
    private var Button_Export: some View {
        Button("Export Graphs") { viewModel.exportSelectionAsDataGraphFiles() }
            .disabled(viewModel.selection.count == 0)
    }

}

#Preview {
    @Previewable var dataListVM = DataListViewModel(DataController(withDelegate: nil),
                                                    SelectionManager(),
                                                    ProcessDataManager(cacheManager: CacheManager(), dataSource: nil))
    DataItemsTableView(dataListVM)
}
