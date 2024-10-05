// Services/BookingService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookingService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var bookings: [Booking] = []
    @Published var errorMessage: String?
    
    /// Fetches bookings for a specific user.
    func fetchBookings(for userID: String) async throws {
        do {
            let snapshot = try await db.collection("bookings")
                .whereField("userID", isEqualTo: userID)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let bookings = snapshot.documents.compactMap { document in
                try? document.data(as: Booking.self)
            }

            DispatchQueue.main.async {
                self.bookings = bookings
            }
        } catch {
            throw AppError.databaseError("Failed to fetch bookings: \(error.localizedDescription)")
        }
    }

    /// Adds a new booking to Firestore.
    func addBooking(_ booking: Booking) async throws {
        do {
            _ = try await db.collection("bookings").addDocument(from: booking)
        } catch {
            throw AppError.databaseError("Failed to add booking: \(error.localizedDescription)")
        }
    }

    /// Updates an existing booking in Firestore.
    func updateBooking(_ booking: Booking) async throws {
        guard let bookingID = booking.id else {
            throw AppError.validationError("Booking ID is missing.")
        }
        do {
            try await db.collection("bookings").document(bookingID).setData(from: booking)
        } catch {
            throw AppError.databaseError("Failed to update booking: \(error.localizedDescription)")
        }
    }

    /// Deletes a booking from Firestore.
    func deleteBooking(_ bookingID: String) async throws {
        do {
            try await db.collection("bookings").document(bookingID).delete()
        } catch {
            throw AppError.databaseError("Failed to delete booking: \(error.localizedDescription)")
        }
    }
}
