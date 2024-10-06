// Models/Vehicle.swift

import Foundation
import FirebaseFirestoreSwift

struct Vehicle: Codable, Identifiable {
    @DocumentID var id: String? // Firestore Document ID
    var ownerID: String
    var make: String
    var model: String
    var year: Int
    var pricePerDay: Double
    var location: String
    var imageURL: String
    var isAvailable: Bool
    var createdAt: Date

    // Initializer
    init(id: String? = nil,
         ownerID: String,
         make: String,
         model: String,
         year: Int,
         pricePerDay: Double,
         location: String,
         imageURL: String,
         isAvailable: Bool = true,
         createdAt: Date = Date()) {
        self.id = id
        self.ownerID = ownerID
        self.make = make
        self.model = model
        self.year = year
        self.pricePerDay = pricePerDay
        self.location = location
        self.imageURL = imageURL
        self.isAvailable = isAvailable
        self.createdAt = createdAt
    }
}
