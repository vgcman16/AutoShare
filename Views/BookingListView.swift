// Views/BookingListView.swift

import SwiftUI

struct BookingListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            if firestoreService.isLoading {
                // Display a loading indicator while data is being fetched
                ProgressView("Loading Bookings...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if let errorMessage = firestoreService.errorMessage {
                // Display error message if there's an error
                VStack {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        fetchData()
                    }) {
                        Text("Retry")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            } else if firestoreService.bookings.isEmpty {
                // Display a message if there are no bookings
                VStack {
                    Text("You have no bookings.")
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button(action: {
                        // Optionally, navigate to a view to make a new booking
                        // For example:
                        // showVehicleList = true
                    }) {
                        Text("Browse Vehicles")
                            .foregroundColor(.blue)
                    }
                }
            } else {
                // Display the list of bookings
                List(firestoreService.bookings) { booking in
                    NavigationLink(destination: BookingDetailView(booking: booking)) {
                        BookingRowView(booking: booking)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("My Bookings")
                .refreshable {
                    // Allow users to pull to refresh
                    fetchData()
                }
            }
        }
        .onAppear {
            fetchData()
        }
    }
    
    /// Fetch both vehicles and bookings for the authenticated user
    private func fetchData() {
        guard let user = authViewModel.user else {
            firestoreService.errorMessage = "User not authenticated."
            return
        }
        
        Task {
            await firestoreService.fetchAvailableVehicles()
            await firestoreService.fetchBookings(for: user.uid)
        }
    }
}

struct BookingListView_Previews: PreviewProvider {
    static var previews: some View {
        BookingListView()
            .environmentObject(FirestoreService())
            .environmentObject(AuthViewModel())
    }
}

