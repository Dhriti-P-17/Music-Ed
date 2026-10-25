//
//  Music_EdApp.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/8/26.
//

import SwiftUI
import SwiftData

@main
struct MusicEdApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UserAccount.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)

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
