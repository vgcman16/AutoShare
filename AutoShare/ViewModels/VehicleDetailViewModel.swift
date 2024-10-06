// ViewModels/VehicleDetailViewModel.swift

import Foundation
import Combine

class VehicleDetailViewModel: ObservableObject {
    @Published var isFavorite: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    var userService: UserService?
    var authViewModel: AuthViewModel?
    let vehicle: Vehicle

    // Initialize with only vehicle
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }

    /// Checks if the vehicle is in the user's favorites.
    func checkIfFavorite(for vehicle: Vehicle) {
        guard let userProfile = userService?.userProfile else { return }
        isFavorite = userProfile.favorites.contains(vehicle.id ?? "")
    }

    /// Toggles the favorite status of the vehicle.
    func toggleFavorite(for vehicle: Vehicle) {
        guard let user = authViewModel?.user else {
            DispatchQueue.main.async {
                self.errorMessage = "User not authenticated."
            }
            return
        }

        isLoading = true
        Task {
            do {
                if isFavorite {
                    try await userService?.removeVehicleFromFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    DispatchQueue.main.async {
                        self.isFavorite = false
                        self.isLoading = false
                    }
                } else {
                    try await userService?.addVehicleToFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    DispatchQueue.main.async {
                        self.isFavorite = true
                        self.isLoading = false
                    }
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
