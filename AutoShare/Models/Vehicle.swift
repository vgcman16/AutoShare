// Models/Vehicle.swift

import Foundation
import FirebaseFirestoreSwift

/// Represents a vehicle available for sharing in the AutoShare app.
struct Vehicle: Identifiable, Codable {
    /// The unique identifier for the vehicle, managed by Firestore.
    @DocumentID var id: String?
    
    /// The make of the vehicle (e.g., Toyota, Ford).
    var make: String
    
    /// The model of the vehicle (e.g., Camry, Mustang).
    var model: String
    
    /// The manufacturing year of the vehicle.
    var year: Int
    
    /// The location where the vehicle is available (e.g., New York, Los Angeles).
    var location: String
    
    /// The URL string pointing to the vehicle's image. Optional in case no image is provided.
    var imageURL: String?
    
    /// The rental price per day for the vehicle.
    var pricePerDay: Double // **Added Property**
    
    /// Indicates whether the vehicle is currently available for sharing.
    var isAvailable: Bool
    
    /// The date and time when the vehicle was added to Firestore.
    var createdAt: Date
    
    /// Coding keys to map Swift property names to Firestore document fields.
    enum CodingKeys: String, CodingKey {
        case id
        case make
        case model
        case year
        case location
        case imageURL
        case pricePerDay // **Updated Coding Keys**
        case isAvailable
        case createdAt
    }
    
    /// Example instance of `Vehicle` for SwiftUI previews and testing.
    static let example = Vehicle(
        id: "vehicle123",
        make: "Toyota",
        model: "Camry",
        year: 2020,
        location: "New York",
        imageURL: "https://example.com/image.jpg",
        pricePerDay: 50.0, // **Example Value**
        isAvailable: true,
        createdAt: Date()
    )
}
