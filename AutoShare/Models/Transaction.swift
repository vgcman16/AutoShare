//
//  Transaction.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//


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
