import SwiftUI
import Firebase

@main
struct AutoShareApp: App {
    // Integrate AppDelegate to handle Firebase configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Initialize ViewModels
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var firestoreService = FirestoreService()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.user != nil {
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(firestoreService)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .environmentObject(firestoreService)
            }
        }
    }
}
