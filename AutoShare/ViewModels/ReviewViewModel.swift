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
            let review = Review(
                vehicleID: vehicleID,
                reviewerID: userID, // Updated parameter name
                rating: rating,
                comment: comment,
                date: Date()
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
