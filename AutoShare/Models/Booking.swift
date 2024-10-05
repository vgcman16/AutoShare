// Models/Booking.swift

import Foundation
import FirebaseFirestoreSwift

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var vehicleID: String
    var startDate: Date
    var endDate: Date
    var rentalDays: Int
    var totalAmount: Double
    var status: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case vehicleID
        case startDate
        case endDate
        case rentalDays
        case totalAmount
        case status
        case createdAt
    }
    
    // Example Booking for Preview
    static let example = Booking(
        userID: "user123",
        vehicleID: "vehicle123",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
        rentalDays: 3,
        totalAmount: 150.00,
        status: "confirmed",
        createdAt: Date()
    )
}
