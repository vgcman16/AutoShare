// ViewModels/UserProfileViewModel.swift

import Foundation
import UIKit

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var isSubmitting: Bool = false

    private let userService: UserService
    private let authViewModel: AuthViewModel

    // Remove default parameters to enforce dependency injection
    init(userService: UserService, authViewModel: AuthViewModel) {
        self.userService = userService
        self.authViewModel = authViewModel
    }

    /// Fetches the user profile.
    func fetchUserProfile() {
        Task {
            // Accessing 'user' directly without 'await' since it's a synchronous property
            guard let user = authViewModel.user else {
                self.errorMessage = "User not authenticated."
                return
            }
            do {
                let profile = try await userService.fetchUserProfile(for: user.uid)
                self.userProfile = profile
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// Updates the user profile.
    func updateUserProfile(fullName: String, selectedImage: UIImage?) {
        Task {
            self.isSubmitting = true
            defer { self.isSubmitting = false }

            // Accessing 'user' directly without 'await' since it's a synchronous property
            guard let user = authViewModel.user else {
                self.errorMessage = "User not authenticated."
                return
            }

            var profileImageURL: String? = self.userProfile?.profileImageURL

            // Upload profile image if selected
            if let image = selectedImage {
                do {
                    profileImageURL = try await ImageUploader.uploadImage(image: image, folder: "profile_images")
                } catch {
                    self.errorMessage = error.localizedDescription
                    return
                }
            }

            // Create a new UserProfile instance with the updated data
            let updatedProfile = UserProfile(
                id: user.uid,
                userID: user.uid,
                fullName: fullName,
                email: user.email ?? "",
                profileImageURL: profileImageURL,
                createdAt: self.userProfile?.createdAt ?? Date()
            )

            do {
                try await userService.updateUserProfile(updatedProfile)
                self.userProfile = updatedProfile
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
