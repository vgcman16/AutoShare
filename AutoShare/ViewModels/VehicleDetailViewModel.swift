// ViewModels/VehicleDetailViewModel.swift

import Foundation

/// ViewModel for VehicleDetailView, managing favorite status and related operations.
class VehicleDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isFavorite: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties

    private let userService: UserService
    private let authViewModel: AuthViewModel
    
    // MARK: - Initializer

    init(vehicle: Vehicle, userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
        checkIfFavorite(for: vehicle)
    }
    
    // MARK: - Methods

    /// Checks if the vehicle is in the user's favorites.
    /// - Parameter vehicle: The vehicle to check.
    func checkIfFavorite(for vehicle: Vehicle) {
        guard let userProfile = userService.userProfile else { return }
        isFavorite = userProfile.favorites.contains(vehicle.id ?? "")
    }
    
    /// Toggles the favorite status of the vehicle.
    /// - Parameter vehicle: The vehicle to toggle.
    func toggleFavorite(for vehicle: Vehicle) {
        Task {
            guard let user = authViewModel.user else {
                DispatchQueue.main.async {
                    self.errorMessage = "User not authenticated."
                }
                return
            }
            do {
                if isFavorite {
                    try await userService.removeVehicleFromFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    DispatchQueue.main.async {
                        self.isFavorite = false
                    }
                } else {
                    try await userService.addVehicleToFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    DispatchQueue.main.async {
                        self.isFavorite = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
