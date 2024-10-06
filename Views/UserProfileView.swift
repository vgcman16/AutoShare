// Views/UserProfileView.swift

import SwiftUI
import Kingfisher

struct UserProfileView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: UserProfileViewModel
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    init() {
        // Initialize the view model with injected services
        // Note: EnvironmentObjects are not accessible in the initializer, so we use a temporary initializer
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userService: UserService(), authViewModel: AuthViewModel()))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image
                if let profileImageURL = viewModel.userProfile?.profileImageURL, !profileImageURL.isEmpty {
                    KFImage(URL(string: profileImageURL))
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .accessibilityLabel("Profile image")
                } else {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text("Upload Profile Image")
                                    .foregroundColor(.white)
                                    .bold()
                            )
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                }

                // Full Name Field
                VStack(alignment: .leading) {
                    Text("Full Name")
                        .font(.headline)
                    TextField("Enter your full name", text: Binding(
                        get: { viewModel.userProfile?.fullName ?? "" },
                        set: { viewModel.userProfile?.fullName = $0 }
                    ))
                    .autocapitalization(.words)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: {
                    viewModel.updateUserProfile(
                        fullName: viewModel.userProfile?.fullName ?? "",
                        selectedImage: selectedImage
                    )
                }) {
                    if viewModel.isSubmitting {
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
                .disabled(viewModel.isSubmitting)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("My Profile")
            .onAppear {
                // Fetch user profile
                viewModel.fetchUserProfile()
            }
        }
    }
}
