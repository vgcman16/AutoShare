// BookingView.swift

import SwiftUI

struct BookingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = BookingViewModel()
    var vehicle: Vehicle
    @Environment(\.presentationMode) var presentationMode

    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { newValue in
                            if endDate < startDate {
                                endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                            }
                        }
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Section(header: Text("Total Amount")) {
                    Text("$\(viewModel.calculateTotalAmount(for: vehicle, startDate: startDate, endDate: endDate), specifier: "%.2f")")
                        .font(.headline)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    Task {
                        guard let userID = authViewModel.user?.uid else {
                            viewModel.errorMessage = "User not authenticated."
                            return
                        }
                        await viewModel.createBooking(for: vehicle, startDate: startDate, endDate: endDate, userID: userID)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    if viewModel.isBooking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    } else {
                        Text("Confirm Booking")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .disabled(viewModel.isBooking)
            }
            .navigationTitle("Book Vehicle")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
