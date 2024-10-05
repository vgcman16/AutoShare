// BookingListView.swift

import SwiftUI

struct BookingListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List(firestoreService.bookings) { booking in
                NavigationLink(destination: BookingDetailView(booking: booking)) {
                    BookingRowView(booking: booking)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Bookings")
            .onAppear {
                if let user = authViewModel.user {
                    firestoreService.fetchBookings(for: user.uid)
                }
            }
        }
    }
}

struct BookingRowView: View {
    var booking: Booking
    @EnvironmentObject var firestoreService: FirestoreService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(getVehicleDetails(vehicleID: booking.vehicleID))
                .font(.headline)
            
            HStack {
                Text("Rental Days: \(booking.rentalDays)")
                Spacer()
                Text("Total: $\(booking.totalAmount, specifier: "%.2f")")
            }
            .font(.subheadline)
            
            HStack {
                Text("Status: \(booking.status.capitalized)")
                    .foregroundColor(statusColor(status: booking.status))
                Spacer()
                Text(formattedDate(booking.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
    
    /// Retrieves vehicle details based on vehicleID
    func getVehicleDetails(vehicleID: String) -> String {
        if let vehicle = firestoreService.vehicles.first(where: { $0.id == vehicleID }) {
            return "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        }
        return "Unknown Vehicle"
    }
    
    /// Formats the date to a readable string
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Determines the color based on booking status
    func statusColor(status: String) -> Color {
        switch status.lowercased() {
        case "confirmed":
            return .green
        case "pending":
            return .orange
        case "completed":
            return .blue
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

struct BookingListView_Previews: PreviewProvider {
    static var previews: some View {
        BookingListView()
            .environmentObject(FirestoreService())
            .environmentObject(AuthViewModel())
    }
}
