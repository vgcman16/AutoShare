import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var fullName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var isSubmitting: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture or Driver's License
                    if let driverLicenseURL = firestoreService.userProfile?.driverLicenseURL, !driverLicenseURL.isEmpty {
                        AsyncImage(url: URL(string: driverLicenseURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 200, height: 150)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 150)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 150)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 200, height: 150)
                                .overlay(
                                    Text("Upload Driver's License")
                                        .foregroundColor(.white)
                                        .bold()
                                )
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: $selectedImage)
                        }
                    }

                    // Full Name Field
                    VStack(alignment: .leading) {
                        Text("Full Name")
                            .font(.headline)
                        TextField("Enter your full name", text: $fullName)
                            .autocapitalization(.words)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    if showError {
                        Text(firestoreService.errorMessage ?? "An error occurred")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        updateProfile()
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        } else {
                            Text("Save Profile")
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
                .padding()
            }
            .navigationTitle("My Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let user = authViewModel.user {
                    firestoreService.fetchUserProfile(for: user.uid) { result in
                        switch result {
                        case .success(let profile):
                            fullName = profile.fullName
                        case .failure(let error):
                            firestoreService.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }

    /// Handles the update of user profile information.
    func updateProfile() {
        guard let user = authViewModel.user else {
            firestoreService.errorMessage = "User not authenticated."
            showError = true
            return
        }

        guard !fullName.isEmpty else {
            firestoreService.errorMessage = "Please enter your full name."
            showError = true
            return
        }

        isSubmitting = true
        showError = false

        let group = DispatchGroup()
        var uploadSuccess = true

        // Update Full Name
        group.enter()
        firestoreService.updateFullName(userID: user.uid, fullName: fullName) { result in
            switch result {
            case .success():
                print("Full name updated.")
            case .failure(let error):
                print("Error updating full name: \(error.localizedDescription)")
                uploadSuccess = false
            }
            group.leave()
        }

        // Upload Driver's License Image if selected
        if let image = selectedImage {
            group.enter()
            ImageUploader.uploadImage(image: image, folder: "driver_license_images") { result in
                switch result {
                case .success(let urlString):
                    firestoreService.updateDriverLicense(userID: user.uid, driverLicenseURL: urlString) { result in
                        switch result {
                        case .success():
                            print("Driver's license updated.")
                        case .failure(let error):
                            print("Error updating driver's license: \(error.localizedDescription)")
                            uploadSuccess = false
                        }
                        group.leave()
                    }
                case .failure(let error):
                    print("Error uploading driver's license image: \(error.localizedDescription)")
                    uploadSuccess = false
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            isSubmitting = false
            if uploadSuccess {
                presentationMode.wrappedValue.dismiss()
            } else {
                firestoreService.errorMessage = "Failed to update profile. Please try again."
                showError = true
            }
        }
    }
}
