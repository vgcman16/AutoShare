// Services/FirestoreService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

/// Service class to handle all Firestore-related operations.
@MainActor // Ensures all published properties are updated on the main thread
class FirestoreService: ObservableObject {
    // MARK: - Properties
    
    /// Reference to the Firestore database.
    private let db = Firestore.firestore()
    
    // MARK: - Published Properties
    
    /// List of all available vehicles.
    @Published var vehicles: [Vehicle] = []
    
    /// List of reviews for a specific vehicle.
    @Published var reviews: [Review] = []
    
    /// The current user's profile.
    @Published var userProfile: UserProfile? = nil
    
    /// List of bookings made by the user.
    @Published var bookings: [Booking] = []
    
    /// List of transactions related to the user.
    @Published var transactions: [Transaction] = []
    
    /// Error message to be displayed in the UI.
    @Published var errorMessage: String?
    
    /// Indicates whether a Firestore operation is in progress.
    @Published var isLoading: Bool = false
    
    // MARK: - Vehicles Operations
    
    /// Fetches all available vehicles (year 2017 and newer) from Firestore.
    func fetchAvailableVehicles() async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("vehicles")
                .whereField("isAvailable", isEqualTo: true)
                .whereField("year", isGreaterThanOrEqualTo: 2017)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedVehicles = try snapshot.documents.map { document in
                try document.data(as: Vehicle.self)
            }
            
            vehicles = fetchedVehicles
            isLoading = false
        } catch {
            errorMessage = "Error fetching vehicles: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Adds a new vehicle to Firestore.
    /// - Parameter vehicle: The `Vehicle` object to be added.
    func addVehicle(vehicle: Vehicle) async throws {
        do {
            try await db.collection("vehicles").addDocument(from: vehicle)
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding vehicle: \(error.localizedDescription)"])
        }
    }
    
    /// Updates an existing vehicle in Firestore.
    /// - Parameter vehicle: The `Vehicle` object with updated data.
    func updateVehicle(vehicle: Vehicle) async throws {
        guard let vehicleID = vehicle.id else {
            throw NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Vehicle ID is missing."])
        }
        
        do {
            try await db.collection("vehicles").document(vehicleID).setData(from: vehicle)
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error updating vehicle: \(error.localizedDescription)"])
        }
    }
    
    /// Deletes a vehicle and all its associated reviews from Firestore.
    /// - Parameter vehicle: The `Vehicle` object to be deleted.
    func deleteVehicle(vehicle: Vehicle) async throws {
        guard let vehicleID = vehicle.id else {
            throw NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Vehicle ID is missing."])
        }
        
        let vehicleRef = db.collection("vehicles").document(vehicleID)
        let reviewsRef = db.collection("reviews").whereField("vehicleID", isEqualTo: vehicleID)
        
        do {
            let reviewSnapshot = try await reviewsRef.getDocuments()
            
            try await db.runTransaction { transaction, errorPointer in
                // Delete the vehicle document.
                transaction.deleteDocument(vehicleRef)
                
                // Delete all associated review documents.
                for document in reviewSnapshot.documents {
                    transaction.deleteDocument(document.reference)
                }
                return nil
            }
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error deleting vehicle and its reviews: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - Reviews Operations
    
    /// Fetches reviews for a specific vehicle from Firestore.
    /// - Parameter vehicleID: The ID of the vehicle.
    func fetchReviews(for vehicleID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("reviews")
                .whereField("vehicleID", isEqualTo: vehicleID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedReviews = try snapshot.documents.map { document in
                try document.data(as: Review.self)
            }
            
            reviews = fetchedReviews
            isLoading = false
        } catch {
            errorMessage = "Error fetching reviews: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Adds a new review to Firestore.
    /// - Parameter review: The `Review` object to be added.
    func addReview(review: Review) async throws {
        do {
            try await db.collection("reviews").addDocument(from: review)
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding review: \(error.localizedDescription)"])
        }
    }
    
    /// Deletes a review from Firestore.
    /// - Parameter review: The `Review` object to be deleted.
    func deleteReview(review: Review) async throws {
        guard let reviewID = review.id else {
            throw NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Review ID is missing."])
        }
        
        do {
            try await db.collection("reviews").document(reviewID).delete()
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error deleting review: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - User Profiles Operations
    
    /// Fetches a user profile from Firestore.
    /// - Parameter userID: The ID of the user.
    /// - Returns: The fetched `UserProfile` object.
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        isLoading = true
        errorMessage = nil
        do {
            let document = try await db.collection("users").document(userID).getDocument()
            
            guard document.exists else {
                throw NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile does not exist."])
            }
            
            let profile = try document.data(as: UserProfile.self)
            userProfile = profile
            isLoading = false
            return profile
        } catch {
            errorMessage = "Error fetching user profile: \(error.localizedDescription)"
            isLoading = false
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error fetching user profile: \(error.localizedDescription)"])
        }
    }
    
    /// Updates a user profile in Firestore.
    /// - Parameter profile: The updated `UserProfile` object.
    func updateUserProfile(profile: UserProfile) async throws {
        let userID = profile.userID
        
        do {
            try await db.collection("users").document(userID).setData(from: profile, merge: true)
            userProfile = profile
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error updating user profile: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - Bookings Operations
    
    /// Fetches bookings for a specific user from Firestore.
    /// - Parameter userID: The ID of the user.
    func fetchBookings(for userID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("bookings")
                .whereField("userID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedBookings = try snapshot.documents.map { document in
                try document.data(as: Booking.self)
            }
            
            bookings = fetchedBookings
            isLoading = false
        } catch {
            errorMessage = "Error fetching bookings: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Adds a new booking to Firestore.
    /// - Parameter booking: The `Booking` object to be added.
    func addBooking(booking: Booking) async throws {
        do {
            try await db.collection("bookings").addDocument(from: booking)
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding booking: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - Transactions Operations
    
    /// Fetches transactions for a specific user from Firestore.
    /// - Parameter userID: The ID of the user.
    func fetchTransactions(for userID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("transactions")
                .whereField("userID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedTransactions = try snapshot.documents.map { document in
                try document.data(as: Transaction.self)
            }
            
            transactions = fetchedTransactions
            isLoading = false
        } catch {
            errorMessage = "Error fetching transactions: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Adds a new transaction to Firestore.
    /// - Parameter transaction: The `Transaction` object to be added.
    func addTransaction(transaction: Transaction) async throws {
        do {
            try await db.collection("transactions").addDocument(from: transaction)
        } catch {
            throw NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error adding transaction: \(error.localizedDescription)"])
        }
    }
}
