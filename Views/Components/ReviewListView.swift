//
//  ReviewListView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/Components/ReviewListView.swift

import SwiftUI

struct ReviewListView: View {
    @StateObject private var viewModel: ReviewViewModel
    var vehicleID: String

    init(vehicleID: String) {
        _viewModel = StateObject(wrappedValue: ReviewViewModel())
        self.vehicleID = vehicleID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reviews")
                .font(.headline)
                .padding(.horizontal)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            if viewModel.reviews.isEmpty {
                Text("No reviews yet.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(viewModel.reviews) { review in
                    ReviewRow(review: review)
                }
            }
        }
        .onAppear {
            viewModel.fetchReviews(for: vehicleID)
        }
    }
}
