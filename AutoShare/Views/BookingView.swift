//
//  BookingView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//


// BookingView.swift

import SwiftUI

struct BookingView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var vehicle: Vehicle
    
    @State private var rentalDays: Int = 1
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingPayment = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Book \(vehicle.make) \(vehicle.model)")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                AsyncImage(url: URL(string: vehicle.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Text("Price: $\(vehicle.pricePerDay, specifier: "%.2f") per day")
                    .font(.headline)
                
                Stepper(value: $rentalDays, in: 1...30) {
                    Text("Rental Days: \(rentalDays)")
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    processBooking()
                }) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    } else {
                        Text("Proceed to Payment")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .disabled(isSubmitting)
                .padding(.horizontal)
                .sheet(isPresented: $showingPayment) {
                    PaymentView()
                        .environmentObject(firestoreService)
                        .environmentObject(authViewModel)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Booking")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    /// Handles the booking process by creating a booking record.
    func processBooking() {
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated."
            return
        }
        
        guard rentalDays >= 1 else {
            errorMessage = "Please select at least one day for rental."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let totalAmount = Double(rentalDays) * vehicle.pricePerDay
        
        let booking = Booking(
            userID: user.uid,
            vehicleID: vehicle.id ?? "",
            rentalDays: rentalDays,
            totalAmount: totalAmount,
            status: "pending",
            createdAt: Date()
        )
        
        firestoreService.addBooking(booking: booking) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success():
                    showingPayment = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
