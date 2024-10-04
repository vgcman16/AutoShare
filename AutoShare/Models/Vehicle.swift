import Foundation
import FirebaseFirestoreSwift

struct Vehicle: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var model: String
    var averageRating: Double?
}
