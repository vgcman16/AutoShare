import SwiftUI

struct VehicleDetailView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingBookingView = false
    @State private var showingAddReview = false
    
    var vehicle: Vehicle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Vehicle Image
                AsyncImage(url: URL(string: vehicle.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Vehicle Details
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                        .font(.title)
                        .bold()
                    
                    Text("Price: $\(vehicle.pricePerDay, specifier: "%.2f") per day")
                        .font(.headline)
                    
                    Text("Location: \(vehicle.location)")
                        .font(.subheadline)
                    
                    if let userProfile = firestoreService.userProfile {
                        Text("Owner: \(userProfile.fullName)")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showingBookingView = true
                    }) {
                        Text("Book Now")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingAddReview = true
                    }) {
                        Text("Add Review")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingBookingView) {
                    BookingView(vehicle: vehicle)
                        .environmentObject(firestoreService)
                        .environmentObject(authViewModel)
                }
                .sheet(isPresented: $showingAddReview) {
                    AddReviewView(vehicle: vehicle)
                        .environmentObject(firestoreService)
                        .environmentObject(authViewModel)
                }
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if firestoreService.reviews.isEmpty {
                        Text("No reviews yet.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(firestoreService.reviews) { review in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("⭐️ \(review.rating)/5")
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text(formattedDate(review.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(review.comment)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Vehicle Details")
        .onAppear {
            firestoreService.fetchReviews(for: vehicle.id ?? "")
            
            if let user = authViewModel.user {
                firestoreService.fetchUserProfile(for: user.uid) { result in
                    switch result {
                    case .success(let profile):
                        print("User profile fetched: \(profile.fullName)")
                    case .failure(let error):
                        firestoreService.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    /// Formats a Date object into a readable string.
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
