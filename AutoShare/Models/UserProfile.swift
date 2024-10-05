// Models/UserProfile.swift

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String // Made non-optional
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
}
