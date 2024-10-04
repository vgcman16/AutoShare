import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    @Published var isLoading: Bool = false
    @Published var authError: String? = nil
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Sign In Function
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.authError = error.localizedDescription
                    completion(.failure(error))
                } else {
                    self?.authError = nil
                    completion(.success(()))
                }
            }
        }
    }
    
    // Sign Up Function
    func signUp(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.authError = error.localizedDescription
                    completion(.failure(error))
                } else if let user = result?.user {
                    // Create a user profile in Firestore
                    let userProfile = UserProfile(id: user.uid, name: name, email: email)
                    Firestore.firestore().collection("userProfiles").document(user.uid).setData([
                        "name": name,
                        "email": email
                    ]) { error in
                        if let error = error {
                            self?.authError = error.localizedDescription
                            completion(.failure(error))
                        } else {
                            self?.authError = nil
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    // Sign Out Function
    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
}
