// AutoShareApp.swift

import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    @StateObject var userService = UserService() // Initialize UserService
    @StateObject var authViewModel = AuthViewModel() // Initialize AuthViewModel
    @StateObject var firestoreService = FirestoreService()
    @StateObject var reviewService = ReviewService()
    // ... Initialize other services as needed
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userService)
                .environmentObject(authViewModel)
                .environmentObject(firestoreService)
                .environmentObject(reviewService)
                // ... Inject other services as needed
        }
    }
}
