// Views/FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    // EnvironmentObjects for injected services
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var vehicleService: VehicleService
    @EnvironmentObject var userService: UserService // Ensure UserService is injected
    
    // Initialize FavoritesViewModel with UserService
    @StateObject private var viewModel: FavoritesViewModel
    
    // Custom initializer to inject environment objects into the view model
    init() {
        // Initialize the view model with UserService, VehicleService, and AuthViewModel
        // Note: EnvironmentObjects are not accessible here, so we initialize with new instances
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(
            userService: UserService(),
            vehicleService: VehicleService(),
            authViewModel: AuthViewModel()
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Display error message if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                // Display message if no favorite vehicles
                else if viewModel.favoriteVehicles.isEmpty {
                    Text("No favorite vehicles yet.")
                        .foregroundColor(.gray)
                        .padding()
                }
                // Display list of favorite vehicles
                else {
                    List(viewModel.favoriteVehicles) { vehicle in
                        NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                            VehicleRow(vehicle: vehicle)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Favorites")
            .onAppear {
                // Load favorites without reassigning viewModel
                viewModel.loadFavorites()
            }
        }
    }
}
