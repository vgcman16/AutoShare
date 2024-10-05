//
//  ReviewsListView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/ReviewsListView.swift

import SwiftUI

struct ReviewsListView: View {
    @State private var reviews: [Review] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var vehicle: Vehicle // The vehicle whose reviews are being displayed
    
    var body: some View {
        List(reviews) { review in
            VStack(alignment: .leading) {
                HStack {
                    RatingView(rating: .constant(review.rating))
                        .frame(width: 100)
                    Spacer()
                    Text(review.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text(review.comment)
                    .font(.body)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Reviews")
        .onAppear(perform: fetchReviews)
        .onReceive(NotificationCenter.default.publisher(for: .reviewAdded)) { _ in
            fetchReviews()
        }
        .overlay(
            if isLoading {
                ProgressView("Loading Reviews...")
            }
        )
        .alert(item: $errorMessage) { errorMsg in
            Alert(title: Text("Error"), message: Text(errorMsg), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Functions
    
    private func fetchReviews() {
        guard let vehicleID = vehicle.id else {
            self.errorMessage = "Invalid vehicle ID."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedReviews = try await FirestoreService.shared.fetchReviews(for: vehicleID)
                DispatchQueue.main.async {
                    self.reviews = fetchedReviews.sorted(by: { $0.createdAt > $1.createdAt })
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
