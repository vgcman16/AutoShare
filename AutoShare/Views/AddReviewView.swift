//
//  AddReviewView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//

import SwiftUI

struct AddReviewView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var vehicle: Vehicle
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil // Local error message instead of binding to FirestoreService
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Review")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // Rating Picker
                VStack(alignment: .leading) {
                    Text("Rating")
                        .font(.headline)
                    Picker("Rating", selection: $rating) {
                        ForEach(1..<6) { num in
                            Text("\(num)").tag(num)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Comment Field
                VStack(alignment: .leading) {
                    Text("Comment")
                        .font(.headline)
                    TextEditor(text: $comment)
                        .frame(height: 150)
                        .padding(4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                if let error = errorMessage, showError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    submitReview()
                }) {
                    if isSubmitting {
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
                .disabled(isSubmitting)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Add Review")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    /// Handles the submission of a new review.
    func submitReview() {
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated."
            showError = true
            return
        }
        
        guard !comment.isEmpty else {
            errorMessage = "Please enter a comment."
            showError = true
            return
        }
        
        isSubmitting = true
        showError = false
        
        let review = Review(
            vehicleID: vehicle.id ?? "",
            reviewerID: user.uid,
            rating: rating,
            comment: comment,
            date: Date()
        )
        
        firestoreService.addReview(review: review) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success():
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
