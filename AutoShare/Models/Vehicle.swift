// Models/Vehicle.swift

import Foundation
import FirebaseFirestoreSwift

struct Vehicle: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    
    // Essential Properties
    var make: String          // Manufacturer of the vehicle (e.g., Toyota, Tesla)
    var model: String         // Model of the vehicle (e.g., Camry, Model S)
    var pricePerDay: Double   // Rental price per day
    var year: Int             // Manufacturing year
    var isAvailable: Bool     // Availability status
    var createdAt: Date       // Date when the vehicle was added to Firestore
    
    // Optional Properties
    var imageURL: String?     // URL to the vehicle's image
    var description: String?  // Description of the vehicle
    var category: String?     // Category or type of vehicle (e.g., SUV, Sedan)
    var mileage: Int?         // Mileage of the vehicle
    var location: String?     // Location where the vehicle is available
    
    enum CodingKeys: String, CodingKey {
        case id
        case make
        case model
        case pricePerDay
        case year
        case isAvailable
        case createdAt
        case imageURL
        case description
        case category
        case mileage
        case location
    }
    
    // Initializer with default values for optional properties
    init(
        id: String? = nil,
        make: String,
        model: String,
        pricePerDay: Double,
        year: Int,
        isAvailable: Bool = true,
        createdAt: Date = Date(),
        imageURL: String? = nil,
        description: String? = nil,
        category: String? = nil,
        mileage: Int? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.pricePerDay = pricePerDay
        self.year = year
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.imageURL = imageURL
        self.description = description
        self.category = category
        self.mileage = mileage
        self.location = location
    }
    
    // Example Vehicle for Preview
    static let example = Vehicle(
        id: "vehicle123",
        make: "Tesla",
        model: "Model S",
        pricePerDay: 150.0,
        year: 2020,
        isAvailable: true,
        createdAt: Date(),
        imageURL: "https://example.com/tesla-model-s.jpg",
        description: "A premium electric sedan with autopilot features.",
        category: "Sedan",
        mileage: 5000,
        location: "San Francisco, CA"
    )
}

