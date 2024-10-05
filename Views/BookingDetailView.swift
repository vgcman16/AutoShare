//
//  BookingDetailView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//


// BookingDetailView.swift

import SwiftUI

struct BookingDetailView: View {
    var booking: Booking
    @EnvironmentObject var firestoreService: FirestoreService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Booking Details")
                .font(.largeTitle)
                .bold()
                .padding()
            
            // Vehicle Image
            if let vehicle = firestoreService.vehicles.first(where: { $0.id == booking.vehicleID }),
               let imageURL = URL(string: vehicle.imageURL) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 300, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 200)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                    .overlay(
                        Text("No Image Available")
                            .foregroundColor(.white)
                    )
            }
            
            // Vehicle Details
            if let vehicle = firestoreService.vehicles.first(where: { $0.id == booking.vehicleID }) {
                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.title2)
                    .bold()
            } else {
                Text("Unknown Vehicle")
                    .font(.title2)
                    .bold()
            }
            
            // Booking Information
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Rental Days:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(booking.rentalDays)")
                }
                
                HStack {
                    Text("Total Amount:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(booking.totalAmount, specifier: "%.2f")")
                }
                
                HStack {
                    Text("Status:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(booking.status.capitalized)
                        .foregroundColor(statusColor(status: booking.status))
                }
                
                HStack {
                    Text("Booked On:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formattedDate(booking.createdAt))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitle("Booking Detail", displayMode: .inline)
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

struct BookingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookingDetailView(booking: Booking(userID: "user123",
                                          vehicleID: "vehicle123",
                                          rentalDays: 3,
                                          totalAmount: 150.00,
                                          status: "confirmed",
                                          createdAt: Date()))
            .environmentObject(FirestoreService())
    }
}
