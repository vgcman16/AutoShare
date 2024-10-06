// AutoShareApp.swift

import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    @StateObject private var firestoreService = FirestoreService()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userService = UserService()
    @StateObject private var vehicleService = VehicleService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firestoreService)
                .environmentObject(authViewModel)
                .environmentObject(userService)
                .environmentObject(vehicleService)
        }
    }
}
