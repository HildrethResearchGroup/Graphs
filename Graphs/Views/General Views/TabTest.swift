//
//  TabTest.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/11/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct TabTest: View {
    var body: some View {
        TabView {
            Text("Received")
                .tabItem({Image(systemName: "tray.and.arrow.down.fill")})
            Text("Sent")
                .tabItem({Image(systemName: "tray.and.arrow.up.fill")})
        }
    }
}


#Preview {
    TabTest()
}
