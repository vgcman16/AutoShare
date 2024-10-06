// Services/UserService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var userProfile: UserProfile? = nil // Ensure this is Optional
    
    /// Saves a new user profile to Firestore.
    func createUserProfile(_ userProfile: UserProfile) async throws {
        do {
            try await db.collection("users").document(userProfile.userID).setData(from: userProfile)
            DispatchQueue.main.async {
                self.userProfile = userProfile
            }
        } catch {
            throw AppError.databaseError("Error creating user profile: \(error.localizedDescription)")
        }
    }
    
    /// Fetches a user profile from Firestore.
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        do {
            let document = try await db.collection("users").document(userID).getDocument()
            
            guard let profile = try document.data(as: UserProfile.self) else {
                throw AppError.databaseError("User profile not found.")
            }
            
            DispatchQueue.main.async {
                self.userProfile = profile
            }
            
            return profile
        } catch {
            throw AppError.databaseError("Error fetching user profile: \(error.localizedDescription)")
        }
    }
    
    /// Updates an existing user profile in Firestore.
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        do {
            try await db.collection("users").document(userProfile.userID).setData(from: userProfile, merge: true)
            DispatchQueue.main.async {
                self.userProfile = userProfile
            }
        } catch {
            throw AppError.databaseError("Error updating user profile: \(error.localizedDescription)")
        }
    }
    
    /// Adds a vehicle to the user's favorites.
    func addVehicleToFavorites(userID: String, vehicleID: String) async throws {
        do {
            // Fetch current user profile
            let userProfile = try await fetchUserProfile(for: userID)
            
            // Check if vehicle is already in favorites
            guard !userProfile.favorites.contains(vehicleID) else {
                throw AppError.validationError("Vehicle is already in favorites.")
            }
            
            // Append the vehicleID to favorites
            var updatedProfile = userProfile
            updatedProfile.favorites.append(vehicleID)
            
            // Update the user profile in Firestore
            try await updateUserProfile(updatedProfile)
        } catch {
            throw error // Propagate the error to be handled by the caller
        }
    }
    
    /// Removes a vehicle from the user's favorites.
    func removeVehicleFromFavorites(userID: String, vehicleID: String) async throws {
        do {
            // Fetch current user profile
            let userProfile = try await fetchUserProfile(for: userID)
            
            // Check if vehicle is in favorites
            guard let index = userProfile.favorites.firstIndex(of: vehicleID) else {
                throw AppError.validationError("Vehicle is not in favorites.")
            }
            
            // Remove the vehicleID from favorites
            var updatedProfile = userProfile
            updatedProfile.favorites.remove(at: index)
            
            // Update the user profile in Firestore
            try await updateUserProfile(updatedProfile)
        } catch {
            throw error // Propagate the error to be handled by the caller
        }
    }
}
