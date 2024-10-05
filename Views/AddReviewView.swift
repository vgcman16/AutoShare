// Views/AddReviewView.swift

import SwiftUI

struct AddReviewView: View {
    @StateObject private var viewModel = ReviewViewModel()
    var vehicleID: String
    @Environment(\.presentationMode) var presentationMode
    @State private var rating: Int = 5
    @State private var comment: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Rate this vehicle")
                    .font(.headline)

                Picker("Rating", selection: $rating) {
                    ForEach(1...5, id: \.self) { star in
                        Text("\(star) Star\(star > 1 ? "s" : "")")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Enter your review", text: $comment)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    viewModel.submitReview(
                        vehicleID: vehicleID,
                        userID: AuthViewModel.shared.user?.uid ?? "",
                        rating: rating,
                        comment: comment
                    )
                    presentationMode.wrappedValue.dismiss()
                }) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    } else {
                        Text("Submit Review")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .disabled(viewModel.isSubmitting)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Review")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
