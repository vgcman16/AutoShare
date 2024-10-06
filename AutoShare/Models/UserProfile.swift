// Models/UserProfile.swift

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String // Non-optional
    var fullName: String
    var email: String
    var driverLicenseURL: String?
    var profileImageURL: String?
    var phoneNumber: String?
    var createdAt: Date
    var favorites: [String] = [] // Array of vehicle IDs
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case fullName
        case email
        case driverLicenseURL
        case profileImageURL
        case phoneNumber
        case createdAt
        case favorites
    }
    
    // Example UserProfile for Preview
    static let example = UserProfile(
        id: "user123",
        userID: "user123",
        fullName: "John Doe",
        email: "john.doe@example.com",
        driverLicenseURL: nil,
        profileImageURL: nil,
        phoneNumber: "123-456-7890",
        createdAt: Date(),
        favorites: []
    )
}
