import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp: Bool = false
    
    // Sign In Fields
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Sign Up Fields
    @State private var name: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $isSignUp, label: Text("Picker")) {
                    Text("Sign In").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isSignUp {
                    // Sign Up Form
                    VStack {
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .padding(.horizontal)
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .padding(.horizontal)
                    }
                } else {
                    // Sign In Form
                    VStack {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                            .padding(.horizontal)
                    }
                }
                
                if let error = authViewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if authViewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                Button(action: {
                    if isSignUp {
                        signUp()
                    } else {
                        signIn()
                    }
                }) {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        }
    }
    
    // MARK: - Authentication Actions
    
    func signIn() {
        authViewModel.signIn(email: email, password: password) { result in
            switch result {
            case .success():
                print("User signed in successfully.")
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
    
    func signUp() {
        authViewModel.signUp(name: name, email: email, password: password) { result in
            switch result {
            case .success():
                print("User signed up successfully.")
            case .failure(let error):
                print("Error signing up: \(error.localizedDescription)")
            }
        }
    }
}
