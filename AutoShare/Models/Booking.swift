// Booking.swift

import Foundation
import FirebaseFirestoreSwift

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var vehicleID: String
    var rentalDays: Int
    var totalAmount: Double
    var status: String // "pending", "confirmed", "completed", "cancelled"
    var createdAt: Date
}
