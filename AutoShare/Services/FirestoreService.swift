import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

class FirestoreService: ObservableObject {
    private var db = Firestore.firestore()
    
    // Published properties to update the UI
    @Published var vehicles: [Vehicle] = []
    @Published var userProfiles: [UserProfile] = []
    @Published var reviews: [Review] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Fetch Functions
    
    // Fetch All Vehicles
    func fetchVehicles() {
        db.collection("vehicles")
            .order(by: "name")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching vehicles: \(error.localizedDescription)")
                    return
                }
                
                self?.vehicles = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Vehicle.self)
                } ?? []
            }
    }
    
    // Fetch User Profiles
    func fetchUserProfiles() {
        db.collection("userProfiles")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching user profiles: \(error.localizedDescription)")
                    return
                }
                
                self?.userProfiles = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: UserProfile.self)
                } ?? []
            }
    }
    
    // Fetch Reviews for a Specific Vehicle
    func fetchReviews(for vehicleID: String) {
        db.collection("reviews")
            .whereField("vehicleID", isEqualTo: vehicleID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching reviews: \(error.localizedDescription)")
                    return
                }
                
                self?.reviews = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Review.self)
                } ?? []
            }
    }
    
    // MARK: - Add Functions
    
    // Add a New Vehicle
    func addVehicle(vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("vehicles").addDocument(from: vehicle) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Vehicle added successfully.")
                    completion(.success(()))
                }
            }
        } catch let error {
            print("Error encoding vehicle: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // Add a New Review
    func addReview(review: Review, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection("reviews").addDocument(from: review) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Review added successfully.")
                    self.calculateAverageRating(for: review.vehicleID)
                    completion(.success(()))
                }
            }
        } catch let error {
            print("Error encoding review: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Helper Functions
    
    // Calculate Average Rating for a Vehicle
    func calculateAverageRating(for vehicleID: String) {
        db.collection("reviews")
            .whereField("vehicleID", isEqualTo: vehicleID)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error calculating average rating: \(error.localizedDescription)")
                    return
                }
                
                let ratings = querySnapshot?.documents.compactMap { document in
                    document.data()["rating"] as? Int
                } ?? []
                
                let average = ratings.isEmpty ? 0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
                
                self?.updateAverageRating(for: vehicleID, average: average)
            }
    }
    
    // Update Average Rating in Vehicle Document
    func updateAverageRating(for vehicleID: String, average: Double) {
        db.collection("vehicles").document(vehicleID).updateData([
            "averageRating": average
        ]) { error in
            if let error = error {
                print("Error updating average rating: \(error.localizedDescription)")
            } else {
                print("Average rating updated to \(average) for vehicle ID: \(vehicleID)")
            }
        }
    }
}
