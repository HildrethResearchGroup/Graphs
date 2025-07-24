//
//  TableInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 11/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct TableInspector: View {
    
    @Bindable var viewModel: TableInspectorViewModel
    
    init(_ viewModel: TableInspectorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text(viewModel.dataItemName)
            Table(of: TableDataRow.self, selection: $viewModel.selection)  {
                TableColumn("#") { (nextRow: TableDataRow) in
                    Text("\(nextRow.rowNumber)")
                        .frame(alignment: .center)
                }
                .width(min: 5, ideal: 10, max: 25)
                TableColumnForEach(viewModel.tableData.columns) { column in
                    TableColumn(column.header) { nextRow in
                        let data = column.data(for: nextRow.rowNumber)
                        Text(data)
                            .frame(alignment: .leading)
                    }
                    .width(min: 15, ideal: 75, max: 150)
                }
            } rows : {
                ForEach(viewModel.tableData.rows) {
                    TableRow($0)
                        .contextMenu { Button_Copy }
                }
            }
            //.alternatingRowBackgrounds(.disabled)
        }
        .onAppear { viewModel.viewIsVisable = true }
        .onDisappear { viewModel.viewIsVisable = false }
    }
    
    
    private var Button_Copy: some View {
        Button("Copy") {
            viewModel.copySelection()
        }
    }
}



 #Preview {
     @Previewable
     @State var viewModel = TableInspectorViewModel(DataController(withDelegate: nil), ProcessDataManager(cacheManager: CacheManager(), dataSource: nil))
     TableInspector(viewModel)
 }
 

extension Int: @retroactive Identifiable {
    public var id: Self { self }
}

