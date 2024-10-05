// Vehicle.swift

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
    var isAvailable: Bool
    var createdAt: Date
}
