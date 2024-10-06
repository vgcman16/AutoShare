// Models/UserProfile.swift

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String? // Firestore Document ID
    var userID: String
    var fullName: String
    var email: String
    var profileImageURL: String?
    var favorites: [String] // <-- Added this property
    var createdAt: Date

    // Initializer
    init(id: String? = nil,
         userID: String,
         fullName: String,
         email: String,
         profileImageURL: String? = nil,
         favorites: [String] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.userID = userID
        self.fullName = fullName
        self.email = email
        self.profileImageURL = profileImageURL
        self.favorites = favorites
        self.createdAt = createdAt
    }
}
