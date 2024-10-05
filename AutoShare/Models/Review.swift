// Review.swift

import Foundation
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var vehicleID: String
    var reviewerID: String
    var rating: Int // 1 to 5
    var comment: String
    var date: Date
}
