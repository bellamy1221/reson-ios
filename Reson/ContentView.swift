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
                    Label("Today", systemImage: "sun.max")
                }

            ProjectsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }

            AIView()
                .tabItem {
                    Label("Coach", systemImage: "sparkles")
                }

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
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
