//
//  TextInspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/9/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import SwiftUI

struct TextInspector: View {
    @State private var viewModel: TextInspectorViewModel

    init(_ viewModel: TextInspectorViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        Text(viewModel.content)
    }
    
}


// MARK: - Preview
#Preview {
    let controller = DataController(withDelegate: nil)
    let viewModel = TextInspectorViewModel(controller)
    TextInspector(viewModel)
}


