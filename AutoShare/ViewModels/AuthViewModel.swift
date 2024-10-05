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
            self?.user = user
            self?.isLoggedIn = user != nil
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
                    completion(true)  // Sign up succeeded
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
                } else {
                    self?.errorMessage = nil
                    self?.user = result?.user
                    completion(true)  // Login succeeded
                }
            }
        }
    }
    
    // Logout Function
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
        }
    }
}
