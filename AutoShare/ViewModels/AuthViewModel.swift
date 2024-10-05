// AuthViewModel.swift

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen to authentication state changes
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoggedIn = user != nil
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Sign Up Function
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)  // Sign up failed
                } else if let user = result?.user {
                    self?.errorMessage = nil
                    self?.user = user
                    self?.isLoggedIn = true
                    completion(true)  // Sign up succeeded

                    // Save additional user data to Firestore
                    self?.saveUserProfile(user: user, fullName: fullName)
                } else {
                    self?.errorMessage = "Unknown error occurred."
                    completion(false)
                }
            }
        }
    }
    
    // Login Function
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)  // Login failed
                } else if let user = result?.user {
                    self?.errorMessage = nil
                    self?.user = user
                    self?.isLoggedIn = true
                    completion(true)  // Login succeeded
                } else {
                    self?.errorMessage = "Unknown error occurred."
                    completion(false)
                }
            }
        }
    }
    
    // Logout Function
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isLoggedIn = false
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.errorMessage = signOutError.localizedDescription
            }
        }
    }

    // Save user profile to Firestore
    private func saveUserProfile(user: User, fullName: String) {
        let userProfile = UserProfile(
            id: user.uid,
            userID: user.uid, // Non-optional
            fullName: fullName,
            email: user.email ?? "",
            createdAt: Date()
        )
        let userService = UserService()
        Task {
            do {
                try await userService.createUserProfile(userProfile)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
