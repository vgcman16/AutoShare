// Models/Review.swift

import Foundation
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var vehicleID: String
    var rating: Int // e.g., 1 to 5
    var comment: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case vehicleID
        case rating
        case comment
        case createdAt
    }
}
