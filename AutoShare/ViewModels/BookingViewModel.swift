// BookingViewModel.swift

import Foundation
import SwiftUI

@MainActor
class BookingViewModel: ObservableObject {
    @Published var isBooking = false
    @Published var errorMessage: String?

    private let firestoreService = FirestoreService()

    func calculateTotalAmount(for vehicle: Vehicle, startDate: Date, endDate: Date) -> Double {
        let rentalDays = max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1, 1)
        return Double(rentalDays) * vehicle.pricePerDay
    }

    func createBooking(for vehicle: Vehicle, startDate: Date, endDate: Date, userID: String) async {
        self.isBooking = true
        self.errorMessage = nil
        do {
            // Calculate total amount
            let totalAmount = calculateTotalAmount(for: vehicle, startDate: startDate, endDate: endDate)

            // Calculate rental days
            let rentalDays = max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1, 1)

            // Create a Booking object
            let booking = Booking(
                id: nil,
                userID: userID,
                vehicleID: vehicle.id ?? UUID().uuidString, // Use UUID if vehicle.id is nil
                startDate: startDate,
                endDate: endDate,
                rentalDays: rentalDays,
                totalAmount: totalAmount,
                status: "pending",
                createdAt: Date()
            )

            // Save booking to Firestore using FirestoreService
            try await firestoreService.addBooking(booking: booking)

            self.isBooking = false
            self.errorMessage = nil
        } catch {
            self.isBooking = false
            self.errorMessage = error.localizedDescription
        }
    }
}
