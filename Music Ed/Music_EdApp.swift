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
    var body: some Scene {
        WindowGroup {
            ContentView() // Or whichever view holds your login/signup logic
        }
        .modelContainer(for: UserAccount.self) // <--- THIS IS REQUIRED
    }
}
