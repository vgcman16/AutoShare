import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back!")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                login()  // Calls the login function within the same scope
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                } else {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Login Failed"), message: Text(authViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
    
    // login function moved inside the scope of LoginView where it has access to email, password, etc.
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            authViewModel.errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        authViewModel.login(email: email, password: password) { success in
            isLoading = false
            if !success {
                showErrorAlert = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(FirestoreService())
    }
}
