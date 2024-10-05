// Services/ReviewViewModel.swift

import Foundation

class ReviewViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var errorMessage: String?
    @Published var isSubmitting: Bool = false

    private let reviewService: ReviewService

    init(reviewService: ReviewService = ReviewService()) {
        self.reviewService = reviewService
    }

    /// Fetches reviews for a specific vehicle.
    func fetchReviews(for vehicleID: String) {
        Task {
            do {
                try await reviewService.fetchReviews(for: vehicleID)
                DispatchQueue.main.async {
                    self.reviews = self.reviewService.reviews
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Submits a new review.
    func submitReview(vehicleID: String, userID: String, rating: Int, comment: String) {
        Task {
            isSubmitting = true
            defer { isSubmitting = false }
            
            // Corrected Review initialization
            let review = Review(
                id: nil, // Assuming id is optional and managed by Firestore
                userID: userID, // Correct parameter name
                vehicleID: vehicleID,
                rating: rating,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                createdAt: Date() // Correct parameter name
            )

            do {
                try await reviewService.addReview(review)
                DispatchQueue.main.async {
                    self.reviews.append(review)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
