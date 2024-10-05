// Transaction.swift

import Foundation
import FirebaseFirestoreSwift

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var vehicleID: String
    var amount: Double
    var date: Date
    var type: String // "rental" or "earning"
}
