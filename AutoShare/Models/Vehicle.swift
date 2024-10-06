import Foundation
import FirebaseFirestoreSwift

struct Vehicle: Codable, Identifiable {
    @DocumentID var id: String? // Firestore Document ID
    var ownerID: String
    var make: String
    var model: String
    var year: Int
    var pricePerDay: Double
    var location: String?
    var imageURL: String?
    var isAvailable: Bool
    var createdAt: Date

    // Initializer
    init(id: String? = nil,
         ownerID: String,
         make: String,
         model: String,
         year: Int,
         pricePerDay: Double,
         location: String? = nil,
         imageURL: String? = nil,
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

    // Static example property for previews and testing purposes
    static let example = Vehicle(
        id: "vehicle123",
        ownerID: "owner123",
        make: "Toyota",
        model: "Camry",
        year: 2020,
        pricePerDay: 50.0,
        location: "New York",
        imageURL: "https://example.com/image.jpg",
        isAvailable: true,
        createdAt: Date()
    )
}
