// Views/BookingView.swift

import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel = BookingViewModel()
    var vehicle: Vehicle
    @Environment(\.presentationMode) var presentationMode
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400) // Next day

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
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
                    viewModel.createBooking(for: vehicle, startDate: startDate, endDate: endDate)
                    presentationMode.wrappedValue.dismiss()
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
