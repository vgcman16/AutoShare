import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    // Initialize FirestoreService
    var firestoreService = FirestoreService()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Fetch initial data if necessary
        firestoreService.fetchUserProfiles()
        firestoreService.fetchVehicles()
        
        return true
    }
}
