//
//  BookingViewModel.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// ViewModels/BookingViewModel.swift

import Foundation

class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var errorMessage: String?
    @Published var isBooking: Bool = false

    private let bookingService: BookingService
    private let authViewModel: AuthViewModel

    init(bookingService: BookingService = BookingService(), authViewModel: AuthViewModel = AuthViewModel()) {
        self.bookingService = bookingService
        self.authViewModel = authViewModel
    }

    /// Fetches bookings for the current user.
    func fetchBookings() {
        Task {
            guard let user = authViewModel.user else { return }
            do {
                try await bookingService.fetchBookings(for: user.uid)
                DispatchQueue.main.async {
                    self.bookings = self.bookingService.bookings
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Creates a new booking.
    func createBooking(for vehicle: Vehicle, startDate: Date, endDate: Date) {
        Task {
            isBooking = true
            defer { isBooking = false }
            guard let user = authViewModel.user else { return }
            let booking = Booking(
                userID: user.uid,
                vehicleID: vehicle.id ?? "",
                startDate: startDate,
                endDate: endDate,
                totalAmount: calculateTotalAmount(for: vehicle, startDate: startDate, endDate: endDate),
                createdAt: Date()
            )

            do {
                try await bookingService.addBooking(booking)
                DispatchQueue.main.async {
                    self.bookings.append(booking)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Calculates the total amount for the booking.
    private func calculateTotalAmount(for vehicle: Vehicle, startDate: Date, endDate: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        return Double(days) * vehicle.pricePerDay
    }
}
