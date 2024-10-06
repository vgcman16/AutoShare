// Views/Components/ReviewRow.swift

import SwiftUI

struct ReviewRow: View {
    var review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("⭐️ \(review.rating)/5")
                    .font(.subheadline)
                    .bold()
                    .accessibilityLabel("Rating: \(review.rating) out of 5")
                Spacer()
                Text(formattedDate(review.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Date: \(formattedDate(review.createdAt))")
            }

            Text(review.comment)
                .font(.body)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    /// Formats a Date object into a readable string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Previews

struct ReviewRow_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of Review directly for the preview
        let exampleReview = Review(
            id: "review123",
            userID: "user123",        // Added userID
            vehicleID: "vehicle123",  // Added vehicleID
            rating: 5,
            comment: "This vehicle was excellent! Highly recommended.",
            createdAt: Date()
        )
        ReviewRow(review: exampleReview)
    }
}
