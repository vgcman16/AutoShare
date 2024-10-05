//
//  UserProfileViewModel.swift
//  AutoShare
//
//  Created by Dustin Wood on 10/5/24.
//


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
            var updatedProfile = userProfile ?? UserProfile(
                id: user.uid,
                userID: user.uid,
                fullName: fullName,
                email: user.email ?? "",
                createdAt: Date()
            )
            updatedProfile.fullName = fullName

            // Upload profile image if selected
            if let image = selectedImage {
                do {
                    let imageURL = try await ImageUploader.uploadImage(image: image, folder: "profile_images")
                    updatedProfile.profileImageURL = imageURL
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
            }

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
}
