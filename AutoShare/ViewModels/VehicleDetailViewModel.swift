//
//  VehicleDetailViewModel.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// ViewModels/VehicleDetailViewModel.swift

import Foundation

class VehicleDetailViewModel: ObservableObject {
    @Published var vehicle: Vehicle
    @Published var isFavorite: Bool = false
    @Published var errorMessage: String?

    private let userService: UserService
    private let authViewModel: AuthViewModel

    init(vehicle: Vehicle, userService: UserService = UserService(), authViewModel: AuthViewModel = AuthViewModel()) {
        self.vehicle = vehicle
        self.userService = userService
        self.authViewModel = authViewModel
        checkIfFavorite()
    }

    /// Checks if the vehicle is in the user's favorites.
    func checkIfFavorite() {
        guard let userProfile = userService.userProfile else { return }
        isFavorite = userProfile.favorites.contains(vehicle.id ?? "")
    }

    /// Toggles the favorite status of the vehicle.
    func toggleFavorite() {
        Task {
            guard let user = authViewModel.user else { return }
            do {
                if isFavorite {
                    try await userService.removeVehicleFromFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    isFavorite = false
                } else {
                    try await userService.addVehicleToFavorites(userID: user.uid, vehicleID: vehicle.id ?? "")
                    isFavorite = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
