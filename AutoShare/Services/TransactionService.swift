// Services/TransactionService.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TransactionService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?

    /// Fetches transactions for a specific user.
    func fetchTransactions(for userID: String) async throws {
        do {
            let snapshot = try await db.collection("transactions")
                .whereField("userID", isEqualTo: userID)
                .order(by: "date", descending: true)
                .getDocuments()

            let transactions = snapshot.documents.compactMap { document in
                try? document.data(as: Transaction.self)
            }

            DispatchQueue.main.async {
                self.transactions = transactions
            }
        } catch {
            throw AppError.databaseError("Failed to fetch transactions: \(error.localizedDescription)")
        }
    }

    /// Adds a new transaction to Firestore.
    func addTransaction(_ transaction: Transaction) async throws {
        do {
            _ = try db.collection("transactions").addDocument(from: transaction)
        } catch {
            throw AppError.databaseError("Failed to add transaction: \(error.localizedDescription)")
        }
    }
}
