import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var errorMessage: String?

    init() {
        listenToAuthChanges()
    }

    // Computed property to check if a user is logged in
    var isLoggedIn: Bool {
        return user != nil
    }

    private func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.user = firebaseUser.map { AppUser(uid: $0.uid, email: $0.email ?? "") }
        }
    }

    /// Signs in the user with email and password.
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email and password are required."
            completion(false)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            guard let firebaseUser = result?.user else {
                self.errorMessage = "Unknown error occurred."
                completion(false)
                return
            }
            self.user = AppUser(uid: firebaseUser.uid, email: firebaseUser.email ?? "")
            self.errorMessage = nil
            completion(true)
        }
    }

    /// Signs up the user with full name, email, and password.
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            self.errorMessage = "All fields are required."
            completion(false)
            return
        }
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters long."
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            guard let firebaseUser = result?.user else {
                self.errorMessage = "Unknown error occurred."
                completion(false)
                return
            }
            self.user = AppUser(uid: firebaseUser.uid, email: firebaseUser.email ?? "")
            self.errorMessage = nil
            completion(true)
        }
    }

    /// Signs out the current user.
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
}

struct AppUser: Identifiable {
    var id: String { uid }
    var uid: String
    var email: String
}
