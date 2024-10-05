import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    // MARK: - Published Properties
    @Published var vehicles: [Vehicle] = []
    @Published var reviews: [Review] = []
    @Published var userProfile: UserProfile? = nil
    @Published var bookings: [Booking] = []
    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?

    // MARK: - Vehicles
    
    // Fetch all available vehicles (2017 and newer)
    func fetchAvailableVehicles() {
        db.collection("vehicles")
            .whereField("isAvailable", isEqualTo: true)
            .whereField("year", isGreaterThanOrEqualTo: 2017)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error fetching vehicles: \(error.localizedDescription)"
                    return
                }
                
                self.vehicles = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Vehicle.self)
                } ?? []
            }
    }

    // Add a new vehicle
    func addVehicle(vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("vehicles").addDocument(from: vehicle)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error adding vehicle: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    // Update a vehicle
    func updateVehicle(vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let vehicleID = vehicle.id else {
            let error = NSError(domain: "Invalid Vehicle ID", code: 400, userInfo: [NSLocalizedDescriptionKey: "Vehicle ID is missing."])
            self.errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        do {
            try db.collection("vehicles").document(vehicleID).setData(from: vehicle)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error updating vehicle: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    // Delete a vehicle and its associated reviews
    func deleteVehicle(vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let vehicleID = vehicle.id else {
            let error = NSError(domain: "Invalid Vehicle ID", code: 400, userInfo: [NSLocalizedDescriptionKey: "Vehicle ID is missing."])
            self.errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        let vehicleRef = db.collection("vehicles").document(vehicleID)
        let reviewsRef = db.collection("reviews").whereField("vehicleID", isEqualTo: vehicleID)

        // Fetch reviews before running transaction
        reviewsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.errorMessage = "Error fetching reviews for vehicle: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }

            // Run the deletion transaction
            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                // Delete the vehicle
                transaction.deleteDocument(vehicleRef)

                // Delete associated reviews
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        transaction.deleteDocument(document.reference)
                    }
                }
                return nil
            }, completion: { (object, error) in
                if let error = error {
                    self.errorMessage = "Transaction failed: \(error.localizedDescription)"
                    completion(.failure(error))
                } else {
                    print("Vehicle and associated reviews deleted successfully.")
                    completion(.success(()))
                }
            })
        }
    }

    // MARK: - Reviews

    // Fetch reviews for a specific vehicle
    func fetchReviews(for vehicleID: String) {
        db.collection("reviews")
            .whereField("vehicleID", isEqualTo: vehicleID)
            .order(by: "date", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error fetching reviews: \(error.localizedDescription)"
                    return
                }

                self.reviews = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Review.self)
                } ?? []
            }
    }

    // Add a new review
    func addReview(review: Review, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("reviews").addDocument(from: review)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error adding review: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    // Delete a review
    func deleteReview(review: Review, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let reviewID = review.id else {
            let error = NSError(domain: "Invalid Review ID", code: 400, userInfo: [NSLocalizedDescriptionKey: "Review ID is missing."])
            self.errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        db.collection("reviews").document(reviewID).delete { error in
            if let error = error {
                self.errorMessage = "Error deleting review: \(error.localizedDescription)"
                completion(.failure(error))
            } else {
                print("Review deleted successfully.")
                completion(.success(()))
            }
        }
    }

    // MARK: - User Profiles

    // Fetch user profile
    func fetchUserProfile(for userID: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("userProfiles").document(userID).getDocument { (document, error) in
            if let error = error {
                self.errorMessage = "Error fetching user profile: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                if let profile = try? document.data(as: UserProfile.self) {
                    completion(.success(profile))
                } else {
                    self.errorMessage = "User profile parsing failed."
                    completion(.failure(NSError(domain: "UserProfile Parsing Error", code: 500)))
                }
            } else {
                self.errorMessage = "User profile does not exist."
                completion(.failure(NSError(domain: "No UserProfile", code: 404)))
            }
        }
    }

    // Update user profile
    func updateUserProfile(profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = profile.userID else {
            let error = NSError(domain: "Invalid User ID", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing."])
            self.errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        do {
            try db.collection("userProfiles").document(userID).setData(from: profile)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error updating profile: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    // Update full name
    func updateFullName(userID: String, fullName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("userProfiles").document(userID).updateData([
            "fullName": fullName
        ]) { error in
            if let error = error {
                self.errorMessage = "Failed to update full name: \(error.localizedDescription)"
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Update driver's license URL
    func updateDriverLicense(userID: String, driverLicenseURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("userProfiles").document(userID).updateData([
            "driverLicenseURL": driverLicenseURL
        ]) { error in
            if let error = error {
                self.errorMessage = "Failed to update driver's license: \(error.localizedDescription)"
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Bookings

    // Fetch bookings for a user
    func fetchBookings(for userID: String) {
        db.collection("bookings")
            .whereField("userID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error fetching bookings: \(error.localizedDescription)"
                    return
                }

                self.bookings = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Booking.self)
                } ?? []
            }
    }

    // Add a new booking
    func addBooking(booking: Booking, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("bookings").addDocument(from: booking)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error adding booking: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }

    // MARK: - Transactions

    // Fetch transactions for a user
    func fetchTransactions(for userID: String) {
        db.collection("transactions")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error fetching transactions: \(error.localizedDescription)"
                    return
                }

                self.transactions = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Transaction.self)
                } ?? []
            }
    }

    // Add a new transaction
    func addTransaction(transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("transactions").addDocument(from: transaction)
            completion(.success(()))
        } catch let error {
            self.errorMessage = "Error adding transaction: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }
}
