//
//  ReviewView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


// Views/ReviewView.swift

import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    
    var vehicle: Vehicle // The vehicle being reviewed
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    RatingView(rating: $rating)
                }
                
                Section(header: Text("Comment")) {
                    TextEditor(text: $comment)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: submitReview) {
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
                    .disabled(isSubmitting || !isFormValid)
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return comment.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    // MARK: - Functions
    
    private func submitReview() {
        guard let userID = authViewModel.user?.uid else {
            self.errorMessage = "You must be logged in to submit a review."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // Create a Review object
        let review = Review(
            id: nil,
            userID: userID,
            vehicleID: vehicle.id ?? "",
            rating: rating,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )
        
        // Submit the review using FirestoreService
        Task {
            do {
                try await FirestoreService.shared.addReview(review)
                
                // Post a notification upon successful submission
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .reviewAdded, object: nil)
                    
                    // Optionally, show a success message or navigate back
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isSubmitting = false
                }
            }
        }
    }
}
