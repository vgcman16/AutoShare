// AddVehicleView.swift

import SwiftUI

struct AddVehicleView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
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
        VStack(spacing: 20) {
            Text("List Your Vehicle")
                .font(.largeTitle)
                .bold()

            TextField("Make", text: $make)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            TextField("Model", text: $model)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            TextField("Year", text: $year)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            TextField("Price Per Day", text: $pricePerDay)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            TextField("Location", text: $location)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

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
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 150)
                        .overlay(
                            Text("Upload Vehicle Image")
                                .foregroundColor(.white)
                        )
                        .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
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
                    Text("List Vehicle")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .disabled(isSubmitting)

            Spacer()
        }
        .padding()
    }

    func submitVehicle() {
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated."
            return
        }

        guard !make.isEmpty, !model.isEmpty, let vehicleYear = Int(year), vehicleYear >= 2017, let price = Double(pricePerDay), !location.isEmpty else {
            errorMessage = "Please fill in all fields correctly. Ensure the year is 2017 or newer."
            return
        }

        guard selectedImage != nil else {
            errorMessage = "Please upload a vehicle image."
            return
        }

        isSubmitting = true
        errorMessage = nil

        // Upload vehicle image
        ImageUploader.uploadImage(image: selectedImage!, folder: "vehicle_images") { result in
            switch result {
            case .success(let urlString):
                // Create vehicle object
                let vehicle = Vehicle(
                    ownerID: user.uid,
                    make: make,
                    model: model,
                    year: vehicleYear,
                    pricePerDay: price,
                    location: location,
                    imageURL: urlString,
                    isAvailable: true,
                    createdAt: Date()
                )

                // Save vehicle to Firestore
                firestoreService.addVehicle(vehicle: vehicle) { result in
                    DispatchQueue.main.async {
                        isSubmitting = false
                        switch result {
                        case .success():
                            // Vehicle added successfully
                            print("Vehicle listed successfully.")
                            // Clear the form
                            make = ""
                            model = ""
                            year = ""
                            pricePerDay = ""
                            location = ""
                            selectedImage = nil
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
