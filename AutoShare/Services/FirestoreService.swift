// Services/FirestoreService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Service class to handle all Firestore-related operations.
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
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let snapshot = try await db.collection("vehicles")
                .whereField("isAvailable", isEqualTo: true)
                .whereField("year", isGreaterThanOrEqualTo: 2017)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedVehicles = snapshot.documents.compactMap { document in
                try? document.data(as: Vehicle.self)
            }
            
            await MainActor.run {
                self.vehicles = fetchedVehicles
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching vehicles: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Adds a new vehicle to Firestore.
    /// - Parameter vehicle: The `Vehicle` object to be added.
    func addVehicle(vehicle: Vehicle) async throws {
        do {
            _ = try await db.collection("vehicles").addDocument(from: vehicle)
        } catch {
            throw error // Propagate the original error
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
            throw error // Propagate the original error
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
            throw error // Propagate the original error
        }
    }
    
    // MARK: - Reviews Operations
    
    /// Fetches reviews for a specific vehicle from Firestore.
    /// - Parameter vehicleID: The ID of the vehicle.
    func fetchReviews(for vehicleID: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let snapshot = try await db.collection("reviews")
                .whereField("vehicleID", isEqualTo: vehicleID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedReviews = snapshot.documents.compactMap { document in
                try? document.data(as: Review.self)
            }
            
            await MainActor.run {
                self.reviews = fetchedReviews
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching reviews: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Adds a new review to Firestore.
    /// - Parameter review: The `Review` object to be added.
    func addReview(review: Review) async throws {
        do {
            _ = try await db.collection("reviews").addDocument(from: review)
        } catch {
            throw error // Propagate the original error
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
            throw error // Propagate the original error
        }
    }
    
    // MARK: - User Profiles Operations
    
    /// Fetches a user profile from Firestore.
    /// - Parameter userID: The ID of the user.
    /// - Returns: The fetched `UserProfile` object.
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let document = try await db.collection("users").document(userID).getDocument()
            
            guard document.exists else {
                throw NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile does not exist."])
            }
            
            let profile = try document.data(as: UserProfile.self)
            await MainActor.run {
                self.userProfile = profile
                self.isLoading = false
            }
            return profile
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching user profile: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error // Propagate the original error
        }
    }
    
    /// Updates a user profile in Firestore.
    /// - Parameter profile: The updated `UserProfile` object.
    func updateUserProfile(profile: UserProfile) async throws {
        let userID = profile.userID
        
        do {
            try await db.collection("users").document(userID).setData(from: profile, merge: true)
            await MainActor.run {
                self.userProfile = profile
            }
        } catch {
            throw error // Propagate the original error
        }
    }
    
    // MARK: - Bookings Operations
    
    /// Fetches bookings for a specific user from Firestore.
    /// - Parameter userID: The ID of the user.
    func fetchBookings(for userID: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let snapshot = try await db.collection("bookings")
                .whereField("userID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedBookings = snapshot.documents.compactMap { document in
                try? document.data(as: Booking.self)
            }
            
            await MainActor.run {
                self.bookings = fetchedBookings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching bookings: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Adds a new booking to Firestore.
    /// - Parameter booking: The `Booking` object to be added.
    func addBooking(booking: Booking) async throws {
        do {
            _ = try await db.collection("bookings").addDocument(from: booking)
        } catch {
            throw error // Propagate the original error
        }
    }
    
    // MARK: - Transactions Operations
    
    /// Fetches transactions for a specific user from Firestore.
    /// - Parameter userID: The ID of the user.
    func fetchTransactions(for userID: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let snapshot = try await db.collection("transactions")
                .whereField("userID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedTransactions = snapshot.documents.compactMap { document in
                try? document.data(as: Transaction.self)
            }
            
            await MainActor.run {
                self.transactions = fetchedTransactions
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching transactions: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Adds a new transaction to Firestore.
    /// - Parameter transaction: The `Transaction` object to be added.
    func addTransaction(transaction: Transaction) async throws {
        do {
            _ = try await db.collection("transactions").addDocument(from: transaction)
        } catch {
            throw error // Propagate the original error
        }
    }
}
