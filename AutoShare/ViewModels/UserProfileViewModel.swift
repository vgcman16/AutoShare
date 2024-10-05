// ViewModels/UserProfileViewModel.swift

import Foundation
import UIKit

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var isSubmitting: Bool = false

    private let userService: UserService
    private let authViewModel: AuthViewModel

    init(userService: UserService = UserService(), authViewModel: AuthViewModel = AuthViewModel()) {
        self.userService = userService
        self.authViewModel = authViewModel
    }

    /// Fetches the user profile.
    func fetchUserProfile() {
        Task {
            guard let user = authViewModel.user else { return }
            do {
                let profile = try await userService.fetchUserProfile(for: user.uid)
                DispatchQueue.main.async {
                    self.userProfile = profile
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Updates the user profile.
    func updateUserProfile(fullName: String, selectedImage: UIImage?) {
        Task {
            isSubmitting = true
            defer { isSubmitting = false }

            guard let user = authViewModel.user else { return }

            var profileImageURL: String? = userProfile?.profileImageURL

            // Upload profile image if selected
            if let image = selectedImage {
                do {
                    profileImageURL = try await ImageUploader.uploadImage(image: image, folder: "profile_images")
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
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
                createdAt: userProfile?.createdAt ?? Date()
            )

            do {
                try await userService.updateUserProfile(updatedProfile)
                DispatchQueue.main.async {
                    self.userProfile = updatedProfile
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
} // <-- Added missing closing brace here

