// Views/VehicleDetailView.swift

import SwiftUI
import Kingfisher

struct VehicleDetailView: View {
    @StateObject private var viewModel: VehicleDetailViewModel
    @State private var showingBookingView = false
    @State private var showingAddReview = false

    init(vehicle: Vehicle) {
        _viewModel = StateObject(wrappedValue: VehicleDetailViewModel(vehicle: vehicle))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Vehicle Image
                KFImage(URL(string: viewModel.vehicle.imageURL))
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipped()
                    .accessibilityLabel("Vehicle image")

                // Vehicle Details
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(viewModel.vehicle.year) \(viewModel.vehicle.make) \(viewModel.vehicle.model)")
                        .font(.title)
                        .bold()
                        .accessibilityLabel("Vehicle: \(viewModel.vehicle.year) \(viewModel.vehicle.make) \(viewModel.vehicle.model)")

                    Text("Price: $\(viewModel.vehicle.pricePerDay, specifier: "%.2f") per day")
                        .font(.headline)

                    Text("Location: \(viewModel.vehicle.location)")
                        .font(.subheadline)
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

                // Favorites Button
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Text(viewModel.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFavorite ? Color.red : Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Reviews Section
                ReviewListView(vehicleID: viewModel.vehicle.id ?? "")
            }
        }
        .navigationTitle("Vehicle Details")
        .sheet(isPresented: $showingBookingView) {
            BookingView(vehicle: viewModel.vehicle)
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(vehicleID: viewModel.vehicle.id ?? "")
        }
    }
}
