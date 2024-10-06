// ViewModels/FavoritesViewModel.swift

import Foundation

@MainActor
class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var favoriteVehicles: [Vehicle] = []
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let userService: UserService
    private let vehicleService: VehicleService
    private let authViewModel: AuthViewModel
    
    // MARK: - Initializer
    
    /// Initializes the FavoritesViewModel with injected services.
    /// - Parameters:
    ///   - userService: The service responsible for user-related Firestore operations.
    ///   - vehicleService: The service responsible for vehicle-related Firestore operations.
    ///   - authViewModel: The view model managing authentication state.
    init(userService: UserService,
         vehicleService: VehicleService,
         authViewModel: AuthViewModel) {
        self.userService = userService
        self.vehicleService = vehicleService
        self.authViewModel = authViewModel
    }
    
    // MARK: - Methods
    
    /// Loads the user's favorite vehicles.
    func loadFavorites() {
        Task {
            // Ensure the user is authenticated
            guard let user = authViewModel.user else {
                self.errorMessage = "User not authenticated."
                return
            }
            
            do {
                // Fetch the user's profile
                let userProfile = try await userService.fetchUserProfile(for: user.uid)
                
                // Check if the user has any favorites
                if !userProfile.favorites.isEmpty {
                    // Fetch vehicles by their IDs
                    let vehicles = try await vehicleService.fetchVehicles(byIDs: userProfile.favorites)
                    
                    // Update the published property
                    self.favoriteVehicles = vehicles
                } else {
                    // If no favorites, clear the list
                    self.favoriteVehicles = []
                }
            } catch {
                // Handle and display errors
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
