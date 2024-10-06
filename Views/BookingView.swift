// Views/BookingView.swift

import SwiftUI

struct BookingView: View {
    // The vehicle being booked
    var vehicle: Vehicle
    
    // ObservedObject for managing booking logic
    @StateObject private var bookingViewModel = BookingViewModel()
    
    // EnvironmentObject to access the authenticated user's information
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Presentation mode to dismiss the view after booking
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for selecting dates
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    // State for showing success alert
    @State private var showSuccessAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Vehicle Image
                    if let imageURL = vehicle.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .cornerRadius(10)
                            .overlay(
                                Text("No Image Available")
                                    .foregroundColor(.white)
                            )
                            .padding(.horizontal)
                    }
                    
                    // Vehicle Details
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                            .font(.title2)
                            .bold()
                        
                        Text("Location: \(vehicle.location)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Price Per Day: $\(vehicle.pricePerDay, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Booking Form
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select Rental Period")
                            .font(.headline)
                        
                        // Start Date Picker
                        DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.horizontal)
                        
                        // End Date Picker
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.horizontal)
                        
                        // Total Amount
                        Text("Total Amount: $\(calculateTotalAmount(), specifier: "%.2f")")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Submit Button
                        Button(action: {
                            submitBooking()
                        }) {
                            HStack {
                                Spacer()
                                if bookingViewModel.isBooking {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                } else {
                                    Text("Book Now")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid() || bookingViewModel.isBooking)
                        .padding(.horizontal)
                        
                        // Error Message
                        if let errorMessage = bookingViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Book Vehicle")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text("Your booking has been created."), dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .onAppear {
            // Optionally, you can fetch user profile or perform other setups here
        }
    }
    
    // MARK: - Helper Functions
    
    /// Calculates the total amount based on rental days and vehicle price per day.
    private func calculateTotalAmount() -> Double {
        let rentalDays = max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1, 1)
        return Double(rentalDays) * vehicle.pricePerDay
    }
    
    /// Checks if the booking form is valid.
    private func isFormValid() -> Bool {
        return endDate > startDate && vehicle.isAvailable
    }
    
    /// Submits the booking using the BookingViewModel.
    private func submitBooking() {
        guard let userID = authViewModel.user?.uid else {
            // Handle unauthenticated state
            bookingViewModel.errorMessage = "You must be logged in to create a booking."
            return
        }
        
        Task {
            await bookingViewModel.createBooking(for: vehicle, startDate: startDate, endDate: endDate, userID: userID)
            
            if bookingViewModel.errorMessage == nil {
                // Booking was successful
                showSuccessAlert = true
            }
        }
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView(vehicle: Vehicle.example)
            .environmentObject(AuthViewModel()) // Inject AuthViewModel
            .environmentObject(UserService())    // Inject UserService if needed
    }
}
