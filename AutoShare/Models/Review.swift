import Foundation
import FirebaseFirestoreSwift

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var vehicleID: String
    var reviewerID: String
    var rating: Int
    var comment: String
    var timestamp: Date
}
