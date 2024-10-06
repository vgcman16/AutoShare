// Views/SignUpView.swift

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showErrorAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
            
            TextField("Full Name", text: $fullName)
                .autocapitalization(.words)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password (Min 6 Characters)", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                signUp()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                } else {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Sign Up Failed"),
                    message: Text(authViewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }
    
    func signUp() {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            authViewModel.errorMessage = "All fields are required."
            showErrorAlert = true
            return
        }
        
        guard password == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match."
            showErrorAlert = true
            return
        }
        
        guard password.count >= 6 else {
            authViewModel.errorMessage = "Password must be at least 6 characters long."
            showErrorAlert = true
            return
        }
        
        isLoading = true
        authViewModel.signUp(email: email, password: password, fullName: fullName) { success in
            isLoading = false
            if !success {
                showErrorAlert = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())  // Inject the environment object here
            .environmentObject(FirestoreService())
    }
}
