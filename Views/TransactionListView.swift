// Views/TransactionListView.swift

import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            if firestoreService.transactions.isEmpty {
                Text("No transactions available.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List(firestoreService.transactions) { transaction in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(transaction.type.capitalized)
                                .font(.headline)
                            Spacer()
                            Text("\(transaction.type == "earning" ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                                .foregroundColor(transaction.type == "earning" ? .green : .red)
                        }
                        Text(formattedDate(transaction.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Vehicle ID: \(transaction.vehicleID)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Transactions")
        .task {
            if let user = authViewModel.user {
                do {
                    try await firestoreService.fetchTransactions(for: user.uid)
                } catch {
                    // Handle the error as needed
                    // For example, you might want to set an error message or log the error
                    // Since firestoreService handles errorMessage, no action is required here
                }
            }
        }
    }

    /// Formats a Date object into a readable string.
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Previews

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide mock data for preview
        let exampleTransaction = Transaction(
            id: "transaction123",
            userID: "user123",
            vehicleID: "vehicle123",
            type: "earning",
            amount: 100.0,
            date: Date()
        )
        
        let mockFirestoreService = FirestoreService()
        mockFirestoreService.transactions = [exampleTransaction]
        
        let authViewModel = AuthViewModel()
        authViewModel.user = User(uid: "user123", email: "user@example.com") // Assuming User struct
        
        return NavigationView {
            TransactionListView()
                .environmentObject(mockFirestoreService)
                .environmentObject(authViewModel)
        }
    }
}
