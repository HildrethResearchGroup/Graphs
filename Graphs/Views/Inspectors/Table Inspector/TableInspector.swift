//
//  TableInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 11/16/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct TableInspector: View {
    
    var viewModel: TableInspectorViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.dataItemName)
            Table(viewModel.tableData.rows)  {
                TableColumn("#") { (nextRow: TableDataRow) in
                    Text("\(nextRow.rowNumber)")
                        .frame(alignment: .center)
                }.width(min: 5, ideal: 10, max: 25)
                TableColumnForEach(viewModel.tableData.columns) { column in
                    TableColumn(column.header) { nextRow in
                        let data = column.data(for: nextRow.rowNumber)
                        Text(data)
                            .frame(alignment: .leading)
                    }
                    .width(min: 15, ideal: 75, max: 150)
                }
            }
        }
        .onAppear { viewModel.viewIsVisable = true }
        .onDisappear { viewModel.viewIsVisable = false }
        
    }
}


/*
 #Preview {
     TableInspector(dataItem: , dataProvider: )
 }
 */

extension Int: @retroactive Identifiable {
    public var id: Self { self }
}

