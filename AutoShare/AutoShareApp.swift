// AutoShareApp.swift

import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    @StateObject var firestoreService = FirestoreService()
    @StateObject var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            BookingListView()
                .environmentObject(firestoreService)
                .environmentObject(authViewModel)
        }
    }
}
