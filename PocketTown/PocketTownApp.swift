//
//  PocketTownApp.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI
import SwiftData

@main
struct PocketTownApp: App {
    /// SwiftDataで保存した値をCloudKitで共有する
    var modelContainer: ModelContainer = {
        let schema = Schema([
            MapPin.self,
        ])
        let config = ModelConfiguration(cloudKitDatabase: .automatic)
        
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(modelContainer)
    }
}
