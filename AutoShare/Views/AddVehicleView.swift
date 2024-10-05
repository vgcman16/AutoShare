//
//  AddVehicleView.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/4/24.
//

import SwiftUI

struct AddVehicleView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var pricePerDay: String = ""
    @State private var location: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var errorMessage: String? = nil
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("List Your Vehicle")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    // Image Picker
                    Button(action: {
                        self.showingImagePicker = true
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 150)
                                .clipped()
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 200, height: 150)
                                .overlay(
                                    Text("Select Image")
                                        .foregroundColor(.white)
                                        .bold()
                                )
                                .cornerRadius(8)
                        }
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                    
                    // Vehicle Details
                    TextField("Make (e.g., Toyota)", text: $make)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    TextField("Model (e.g., Camry)", text: $model)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    TextField("Year (2017 and newer)", text: $year)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    TextField("Price Per Day ($)", text: $pricePerDay)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    TextField("Location (e.g., Chicago)", text: $location)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        submitVehicle()
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        } else {
                            Text("Submit")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(isSubmitting)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Vehicle")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    /// Handles the submission of a new vehicle listing.
    func submitVehicle() {
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated."
            return
        }
        
        guard !make.isEmpty, !model.isEmpty, let yearInt = Int(year),
              yearInt >= 2017,
              !pricePerDay.isEmpty, let price = Double(pricePerDay),
              !location.isEmpty, let image = selectedImage else {
            if let yearInt = Int(year), yearInt < 2017 {
                errorMessage = "Please enter a year of 2017 or newer."
            } else {
                errorMessage = "Please fill in all fields correctly and select an image."
            }
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // Upload image to Firebase Storage
        ImageUploader.uploadImage(image: image, folder: "vehicle_images") { result in
            switch result {
            case .success(let urlString):
                let vehicle = Vehicle(
                    ownerID: user.uid,
                    make: make,
                    model: model,
                    year: yearInt,
                    pricePerDay: price,
                    location: location,
                    imageURL: urlString,
                    isAvailable: true,
                    createdAt: Date()
                )
                
                firestoreService.addVehicle(vehicle: vehicle) { result in
                    DispatchQueue.main.async {
                        isSubmitting = false
                        switch result {
                        case .success():
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
