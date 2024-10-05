//
//  ReviewRow.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


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
                Text(formattedDate(review.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Date: \(formattedDate(review.date))")
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
