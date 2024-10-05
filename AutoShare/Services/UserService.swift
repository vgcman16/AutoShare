// Services/UserService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?

    /// Fetches the user profile for a specific user ID.
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        do {
            let document = try await db.collection("userProfiles").document(userID).getDocument()
            if let profile = try document.data(as: UserProfile.self) {
                DispatchQueue.main.async {
                    self.userProfile = profile
                }
                return profile
            } else {
                throw AppError.databaseError("User profile does not exist.")
            }
        } catch {
            throw AppError.databaseError("Failed to fetch user profile: \(error.localizedDescription)")
        }
    }

    /// Updates the user profile in Firestore.
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let userID = profile.userID else {
            throw AppError.validationError("User ID is missing.")
        }
        do {
            try db.collection("userProfiles").document(userID).setData(from: profile)
        } catch {
            throw AppError.databaseError("Failed to update user profile: \(error.localizedDescription)")
        }
    }

    /// Adds a vehicle to the user's favorites.
    func addVehicleToFavorites(userID: String, vehicleID: String) async throws {
        let userRef = db.collection("userProfiles").document(userID)
        do {
            try await userRef.updateData([
                "favorites": FieldValue.arrayUnion([vehicleID])
            ])
        } catch {
            throw AppError.databaseError("Failed to add vehicle to favorites: \(error.localizedDescription)")
        }
    }

    /// Removes a vehicle from the user's favorites.
    func removeVehicleFromFavorites(userID: String, vehicleID: String) async throws {
        let userRef = db.collection("userProfiles").document(userID)
        do {
            try await userRef.updateData([
                "favorites": FieldValue.arrayRemove([vehicleID])
            ])
        } catch {
            throw AppError.databaseError("Failed to remove vehicle from favorites: \(error.localizedDescription)")
        }
    }
}
