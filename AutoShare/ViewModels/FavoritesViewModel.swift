//
//  FavoritesViewModel.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// ViewModels/FavoritesViewModel.swift

import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoriteVehicles: [Vehicle] = []
    @Published var errorMessage: String?

    private let userService: UserService
    private let vehicleService: VehicleService
    private let authViewModel: AuthViewModel

    init(userService: UserService = UserService(), vehicleService: VehicleService = VehicleService(), authViewModel: AuthViewModel = AuthViewModel()) {
        self.userService = userService
        self.vehicleService = vehicleService
        self.authViewModel = authViewModel
    }

    /// Loads the user's favorite vehicles.
    func loadFavorites() {
        Task {
            guard let user = authViewModel.user else { return }
            do {
                let userProfile = try await userService.fetchUserProfile(for: user.uid)
                if !userProfile.favorites.isEmpty {
                    let vehicles = try await vehicleService.fetchVehicles(byIDs: userProfile.favorites)
                    DispatchQueue.main.async {
                        self.favoriteVehicles = vehicles
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
