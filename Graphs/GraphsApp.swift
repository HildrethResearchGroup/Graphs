//
//  GraphsApp.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/4/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct GraphsApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State var appController = AppController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(appController)
        
        Settings {
            Preferences()
        }
    }
    
}


