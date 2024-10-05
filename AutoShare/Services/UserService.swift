// Services/UserService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserService {
    private let db = Firestore.firestore()

    /// Saves a new user profile to Firestore.
    func createUserProfile(_ userProfile: UserProfile) async throws {
        // Since userID is non-optional, use it directly
        let userID = userProfile.userID
        try await db.collection("users").document(userID).setData(from: userProfile)
    }

    /// Fetches a user profile from Firestore.
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        let document = try await db.collection("users").document(userID).getDocument()
        guard let profile = try document.data(as: UserProfile.self) else {
            // Use centralized AppError instead of NSError
            throw AppError.databaseError("User profile not found.")
        }
        return profile
    }

    /// Updates an existing user profile in Firestore.
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        // Since userID is non-optional, use it directly
        let userID = userProfile.userID
        try await db.collection("users").document(userID).setData(from: userProfile, merge: true)
    }
}

