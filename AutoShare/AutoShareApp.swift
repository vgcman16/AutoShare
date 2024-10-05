// AutoShareApp.swift

import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    @StateObject var firestoreService = FirestoreService()
    @StateObject var reviewService = ReviewService() // Instantiate ReviewService
    @StateObject var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firestoreService)
                .environmentObject(reviewService) // Inject ReviewService
                .environmentObject(authViewModel)
        }
    }
}
