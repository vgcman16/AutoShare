// Services/ReviewService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ReviewService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var reviews: [Review] = []
    @Published var errorMessage: String?

    /// Fetches reviews for a specific vehicle.
    func fetchReviews(for vehicleID: String) async throws {
        do {
            let snapshot = try await db.collection("reviews")
                .whereField("vehicleID", isEqualTo: vehicleID)
                .order(by: "date", descending: true)
                .getDocuments()

            let reviews = snapshot.documents.compactMap { document in
                try? document.data(as: Review.self)
            }

            DispatchQueue.main.async {
                self.reviews = reviews
            }
        } catch {
            throw AppError.databaseError("Failed to fetch reviews: \(error.localizedDescription)")
        }
    }

    /// Adds a new review to Firestore.
    func addReview(_ review: Review) async throws {
        do {
            _ = try db.collection("reviews").addDocument(from: review)
        } catch {
            throw AppError.databaseError("Failed to add review: \(error.localizedDescription)")
        }
    }
}
