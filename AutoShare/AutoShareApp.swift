// AutoShareApp.swift

import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var firestoreService = FirestoreService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(firestoreService)
        }
    }
}
