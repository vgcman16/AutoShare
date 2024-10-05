import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String? // Make userID optional to handle cases where it might be missing
    var fullName: String
    var email: String
    var driverLicenseURL: String?
    var profileImageURL: String?
    var phoneNumber: String?
    var createdAt: Date
    
    // Optional: Additional fields can be added here as needed
}

