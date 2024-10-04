import SwiftUI

struct VehicleDetailView: View {
    var vehicle: Vehicle
    @EnvironmentObject var firestoreService: FirestoreService
    @State private var showingAddReview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(vehicle.name)
                .font(.largeTitle)
                .bold()
            
            Text("Model: \(vehicle.model)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            if let rating = vehicle.averageRating {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Text("Reviews")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
            
            if firestoreService.reviews.isEmpty {
                Text("No reviews yet.")
                    .foregroundColor(.secondary)
            } else {
                List(firestoreService.reviews) { review in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Rating: \(review.rating)/5")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(review.timestamp, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(review.comment)
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            firestoreService.fetchReviews(for: vehicle.id ?? "")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddReview = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Review")
            }
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(vehicle: vehicle)
                .environmentObject(firestoreService)
        }
    }
}
