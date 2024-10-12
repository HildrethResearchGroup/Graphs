//
//  UUID_Extensions.swift
//  Graphs
//
//  Created by Owen Hildreth on 7/18/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UUID: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(for: UUID.self, contentType: .uuid)
    }
}


extension UTType {
    static var uuid = UTType(exportedAs: "edu.HRG.UUID")
}
