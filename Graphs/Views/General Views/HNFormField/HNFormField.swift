//
//  HNFormField.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/19/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

struct HNFormField<RightContent: View>: View {
    
    var name: String
    @ViewBuilder let rightContent: RightContent
    
    private let viewWidths = ViewWidths()

    
    init(_ name: String, @ViewBuilder _ rightContent: () -> RightContent) {
        self.name = name
        self.rightContent = rightContent()
    }
    
    var body: some View {
        HStack {
            Text(name)
                .frame(width: viewWidths.leftForm, alignment: .leading)
                .border(.red)
            Spacer()
            rightContent
                .frame(width: viewWidths.rightForm, alignment: .trailing)
                .border(.red)
        }
    }
}





#Preview {
    HNFormField("Name") {Text("RightView")}
    
}
