// Models/Vehicle.swift

import Foundation
import FirebaseFirestoreSwift

struct Vehicle: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerID: String
    var make: String
    var model: String
    var year: Int
    var pricePerDay: Double
    var location: String
    var imageURL: String
    var isAvailable: Bool = true
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case id
        case ownerID
        case make
        case model
        case year
        case pricePerDay
        case location
        case imageURL
        case isAvailable
        case createdAt
    }
}
