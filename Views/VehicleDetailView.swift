// Views/VehicleDetailView.swift

import SwiftUI

struct VehicleDetailView: View {
    // MARK: - Properties

    var vehicle: Vehicle

    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var viewModel: VehicleDetailViewModel

    // Dismiss environment variable
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Initializer

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        // Initialize viewModel with only vehicle; dependencies will be set in onAppear
        _viewModel = StateObject(wrappedValue: VehicleDetailViewModel(vehicle: vehicle))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            // Vehicle Image
            if let imageURL = vehicle.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }

            // Vehicle Details
            VStack(alignment: .leading, spacing: 5) {
                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Location: \(vehicle.location ?? "Unknown")") // Safely unwrap if optional
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Price per Day: $\(vehicle.pricePerDay, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Favorite Button
            Button(action: {
                viewModel.toggleFavorite(for: vehicle)
            }) {
                HStack {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite ? .red : .gray)
                    Text(viewModel.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)

            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Assign the shared UserService and AuthViewModel to the viewModel
            viewModel.userService = userService
            viewModel.authViewModel = authViewModel
            viewModel.checkIfFavorite(for: vehicle)
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Previews

struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleVehicle = Vehicle(
            id: "vehicle123",
            make: "Toyota",
            model: "Camry",
            year: 2020,
            location: "New York",
            imageURL: "https://example.com/image.jpg",
            pricePerDay: 50.0,
            isAvailable: true,
            createdAt: Date()
        )
        let userService = UserService()
        let authViewModel = AuthViewModel()

        VehicleDetailView(vehicle: exampleVehicle)
            .environmentObject(userService)
            .environmentObject(authViewModel)
    }
}
