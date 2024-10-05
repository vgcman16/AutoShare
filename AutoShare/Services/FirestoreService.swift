// Services/FirestoreService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    // MARK: - Published Properties
    @Published var vehicles: [Vehicle] = []
    @Published var reviews: [Review] = []
    @Published var userProfile: UserProfile? = nil
    @Published var bookings: [Booking] = []
    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Vehicles
    
    /// Fetch all available vehicles (2017 and newer)
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

            let vehicles = snapshot.documents.compactMap { document in
                try? document.data(as: Vehicle.self)
            }

            await MainActor.run {
                self.vehicles = vehicles
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching vehicles: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Add a new vehicle
    func addVehicle(vehicle: Vehicle) async throws {
        do {
            _ = try await db.collection("vehicles").addDocument(from: vehicle)
        } catch {
            throw AppError.databaseError("Error adding vehicle: \(error.localizedDescription)")
        }
    }

    /// Update a vehicle
    func updateVehicle(vehicle: Vehicle) async throws {
        guard let vehicleID = vehicle.id else {
            throw AppError.validationError("Vehicle ID is missing.")
        }

        do {
            try await db.collection("vehicles").document(vehicleID).setData(from: vehicle)
        } catch {
            throw AppError.databaseError("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    /// Delete a vehicle and its associated reviews
    func deleteVehicle(vehicle: Vehicle) async throws {
        guard let vehicleID = vehicle.id else {
            throw AppError.validationError("Vehicle ID is missing.")
        }

        let vehicleRef = db.collection("vehicles").document(vehicleID)
        let reviewsRef = db.collection("reviews").whereField("vehicleID", isEqualTo: vehicleID)

        do {
            let reviewSnapshot = try await reviewsRef.getDocuments()

            try await db.runTransaction { transaction, errorPointer in
                // Delete the vehicle
                transaction.deleteDocument(vehicleRef)

                // Delete associated reviews
                for document in reviewSnapshot.documents {
                    transaction.deleteDocument(document.reference)
                }
                return nil
            }
        } catch {
            throw AppError.databaseError("Error deleting vehicle: \(error.localizedDescription)")
        }
    }

    // MARK: - Reviews
    
    /// Fetch reviews for a specific vehicle
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

            let reviews = snapshot.documents.compactMap { document in
                try? document.data(as: Review.self)
            }

            await MainActor.run {
                self.reviews = reviews
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching reviews: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Add a new review
    func addReview(review: Review) async throws {
        do {
            _ = try await db.collection("reviews").addDocument(from: review)
        } catch {
            throw AppError.databaseError("Error adding review: \(error.localizedDescription)")
        }
    }

    /// Delete a review
    func deleteReview(review: Review) async throws {
        guard let reviewID = review.id else {
            throw AppError.validationError("Review ID is missing.")
        }

        do {
            try await db.collection("reviews").document(reviewID).delete()
        } catch {
            throw AppError.databaseError("Error deleting review: \(error.localizedDescription)")
        }
    }

    // MARK: - User Profiles
    
    /// Fetch user profile
    func fetchUserProfile(for userID: String) async throws -> UserProfile {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let document = try await db.collection("users").document(userID).getDocument()

            guard document.exists else {
                throw AppError.databaseError("User profile does not exist.")
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
            throw error
        }
    }

    /// Update user profile
    func updateUserProfile(profile: UserProfile) async throws {
        // Since userID is non-optional, use it directly
        let userID = profile.userID

        do {
            try await db.collection("users").document(userID).setData(from: profile, merge: true)
        } catch {
            throw AppError.databaseError("Error updating profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Bookings
    
    /// Fetch bookings for a user
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

            let bookings = snapshot.documents.compactMap { document in
                try? document.data(as: Booking.self)
            }

            await MainActor.run {
                self.bookings = bookings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching bookings: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Add a new booking
    func addBooking(booking: Booking) async throws {
        do {
            _ = try await db.collection("bookings").addDocument(from: booking)
        } catch {
            throw AppError.databaseError("Failed to add booking: \(error.localizedDescription)")
        }
    }

    // MARK: - Transactions
    
    /// Fetch transactions for a user
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

            let transactions = snapshot.documents.compactMap { document in
                try? document.data(as: Transaction.self)
            }

            await MainActor.run {
                self.transactions = transactions
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching transactions: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Add a new transaction
    func addTransaction(transaction: Transaction) async throws {
        do {
            _ = try await db.collection("transactions").addDocument(from: transaction)
        } catch {
            throw AppError.databaseError("Failed to add transaction: \(error.localizedDescription)")
        }
    }
}

