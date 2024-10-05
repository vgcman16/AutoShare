// Services/VehicleService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class VehicleService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var vehicles: [Vehicle] = []
    @Published var errorMessage: String?

    /// Fetches all available vehicles (2017 and newer) from Firestore.
    func fetchAvailableVehicles() async throws {
        do {
            let snapshot = try await db.collection("vehicles")
                .whereField("isAvailable", isEqualTo: true)
                .whereField("year", isGreaterThanOrEqualTo: 2017)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let vehicles = snapshot.documents.compactMap { document in
                try? document.data(as: Vehicle.self)
            }

            DispatchQueue.main.async {
                self.vehicles = vehicles
            }
        } catch {
            throw AppError.databaseError("Failed to fetch vehicles: \(error.localizedDescription)")
        }
    }

    /// Fetches vehicles by their IDs.
    func fetchVehicles(byIDs ids: [String]) async throws -> [Vehicle] {
        var vehicles: [Vehicle] = []
        for id in ids {
            do {
                let document = try await db.collection("vehicles").document(id).getDocument()
                if let vehicle = try document.data(as: Vehicle.self) {
                    vehicles.append(vehicle)
                }
            } catch {
                throw AppError.databaseError("Failed to fetch vehicle with ID \(id): \(error.localizedDescription)")
            }
        }
        return vehicles
    }

    /// Adds a new vehicle to Firestore.
    func addVehicle(_ vehicle: Vehicle) async throws {
        do {
            _ = try db.collection("vehicles").addDocument(from: vehicle)
        } catch {
            throw AppError.databaseError("Failed to add vehicle: \(error.localizedDescription)")
        }
    }

    /// Updates an existing vehicle in Firestore.
    func updateVehicle(_ vehicle: Vehicle) async throws {
        guard let vehicleID = vehicle.id else {
            throw AppError.validationError("Vehicle ID is missing.")
        }
        do {
            try db.collection("vehicles").document(vehicleID).setData(from: vehicle)
        } catch {
            throw AppError.databaseError("Failed to update vehicle: \(error.localizedDescription)")
        }
    }

    /// Deletes a vehicle from Firestore.
    func deleteVehicle(_ vehicleID: String) async throws {
        do {
            try await db.collection("vehicles").document(vehicleID).delete()
        } catch {
            throw AppError.databaseError("Failed to delete vehicle: \(error.localizedDescription)")
        }
    }
}
