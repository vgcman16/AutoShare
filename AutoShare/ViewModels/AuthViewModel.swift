// ViewModels/AuthViewModel.swift

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = nil // Firebase Auth User

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /// Listens to authentication state changes.
    private func listenToAuthChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    /// Signs out the current user.
    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Signs in the user with email and password.
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }

    /// Registers a new user with email and password.
    func register(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = result.user
    }
}
