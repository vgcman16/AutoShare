// ViewModels/AuthViewModel.swift

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String? // <-- Added this property

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    /// Signs in the user with email and password.
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                self?.errorMessage = nil
                completion(true)
            }
        }
    }

    /// Signs up the user with full name, email, and password.
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                // Optionally, you can update the user's display name or other profile information here.
                self?.errorMessage = nil
                completion(true)
            }
        }
    }

    /// Signs out the current user.
    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
}
