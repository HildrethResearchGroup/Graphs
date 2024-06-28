//
//  Inspector.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI

struct Inspector: View {
    var body: some View {
        TabView {
            ParserInspector()
                .tabItem { Image(systemName: "list.dash") }
            GraphTemplateInspector()
                .tabItem { Image(systemName: "waveform.path.ecg.rectangle") }
        }
    }
}

#Preview {
    Inspector()
}
