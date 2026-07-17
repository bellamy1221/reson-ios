//
//  ContentView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }

            AIView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }

            BoardView()
                .tabItem {
                    Label("Board", systemImage: "rectangle.3.group")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
