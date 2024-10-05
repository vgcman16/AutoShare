// TransactionListView.swift

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
        .onAppear {
            if let user = authViewModel.user {
                firestoreService.fetchTransactions(for: user.uid)
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
