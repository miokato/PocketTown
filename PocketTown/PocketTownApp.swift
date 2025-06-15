//
//  PocketTownApp.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

@main
struct PocketTownApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: MapPin.self)
    }
}
