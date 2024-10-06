// ViewModels/VehicleListViewModel.swift

import Foundation
import Combine

class VehicleListViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var filteredVehicles: [Vehicle] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    
    private let vehicleService: VehicleService
    private var cancellables = Set<AnyCancellable>()
    
    init(vehicleService: VehicleService = VehicleService()) {
        self.vehicleService = vehicleService
        setupBindings()
    }
    
    /// Sets up bindings for search text changes.
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.filterVehicles(by: text)
            }
            .store(in: &cancellables)
    }
    
    /// Fetches available vehicles from the service.
    func fetchVehicles() {
        Task {
            do {
                try await vehicleService.fetchAvailableVehicles()
                DispatchQueue.main.async {
                    self.vehicles = self.vehicleService.vehicles
                    self.filteredVehicles = self.vehicles
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Filters vehicles based on the search text.
    private func filterVehicles(by text: String) {
        if text.isEmpty {
            filteredVehicles = vehicles
        } else {
            filteredVehicles = vehicles.filter { vehicle in
                vehicle.make.localizedCaseInsensitiveContains(text) ||
                vehicle.model.localizedCaseInsensitiveContains(text) ||
                (vehicle.location?.localizedCaseInsensitiveContains(text) ?? false)
            }
        }
    }
}
