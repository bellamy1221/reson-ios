//
//  ResonApp.swift
//  Reson
//
//  Created by ramsyyy tt on 7/17/26.
//

import SwiftUI
import SwiftData

@main
struct ResonApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            TaskItem.self,
            ProjectItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
