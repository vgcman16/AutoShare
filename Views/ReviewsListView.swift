// Views/ReviewsListView.swift

import SwiftUI

// 1. Define an Identifiable wrapper for error messages
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

struct ReviewsListView: View {
    // 2. Inject FirestoreService as an EnvironmentObject
    @EnvironmentObject var firestoreService: FirestoreService
    
    @State private var reviews: [Review] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: ErrorWrapper? = nil // Changed from String? to ErrorWrapper?
    
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
            Group {
                if isLoading {
                    ProgressView("Loading Reviews...")
                }
            }
        )
        // 3. Use the Identifiable ErrorWrapper in the alert
        .alert(item: $errorMessage) { errorMsg in
            Alert(
                title: Text("Error"),
                message: Text(errorMsg.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Functions
    
    private func fetchReviews() {
        guard let vehicleID = vehicle.id else {
            self.errorMessage = ErrorWrapper(message: "Invalid vehicle ID.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 4. Use the injected FirestoreService instance
                let fetchedReviews = try await firestoreService.fetchReviews(for: vehicleID)
                // Since the class is @MainActor, no need to dispatch to main thread
                self.reviews = fetchedReviews.sorted(by: { $0.createdAt > $1.createdAt })
                self.isLoading = false
            } catch {
                self.errorMessage = ErrorWrapper(message: error.localizedDescription)
                self.isLoading = false
            }
        }
    }
}

// MARK: - Previews

struct ReviewsListView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide mock data for preview
        let exampleVehicle = Vehicle(
            id: "vehicle123",
            ownerID: "owner123",
            make: "Toyota",
            model: "Camry",
            year: 2020,
            pricePerDay: 50.0,
            location: "New York",
            imageURL: "https://example.com/image.jpg",
            isAvailable: true,
            createdAt: Date()
        )
        
        let exampleReview = Review(
            id: "review123",
            userID: "user123",
            vehicleID: "vehicle123",
            rating: 4,
            comment: "Great vehicle, very comfortable!",
            createdAt: Date()
        )
        
        let mockFirestoreService = FirestoreService()
        // Assuming FirestoreService has a method to set mock data for previews
        mockFirestoreService.mockReviews = [exampleReview]
        
        return NavigationView {
            ReviewsListView(vehicle: exampleVehicle)
                .environmentObject(mockFirestoreService)
        }
    }
}
