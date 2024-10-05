import SwiftUI
import Stripe

struct PaymentView: View {
    @EnvironmentObject var paymentViewModel: PaymentViewModel
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Preparing Payment...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else if paymentViewModel.paymentSheet != nil {
                Text("Processing Payment...")
                    .font(.headline)
                
                Button(action: {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let topVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                        paymentViewModel.presentPaymentSheet(from: topVC)
                    }
                }) {
                    Text("Pay Now")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            } else {
                Text("Payment Setup Failed.")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Payment")
        .onAppear {
            preparePayment()
        }
    }
    
    /// Prepares the PaymentSheet by fetching necessary payment details from the backend.
    func preparePayment() {
        guard authViewModel.user != nil else {
            errorMessage = "User not authenticated."
            isLoading = false
            return
        }
        
        // Placeholder: Replace with actual network call to your backend to create PaymentIntent
        // and retrieve customerID, ephemeralKeySecret, and paymentIntentClientSecret.
        // For demonstration, we'll use dummy data after a delay.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Dummy data
            let customerID = "cus_123456789"
            let ephemeralKeySecret = "ek_test_abcdef123456"
            let paymentIntentClientSecret = "pi_test_abcdef123456_secret_abcdef"
            
            paymentViewModel.preparePaymentSheet(customerID: customerID, ephemeralKeySecret: ephemeralKeySecret, paymentIntentClientSecret: paymentIntentClientSecret)
            isLoading = false
        }
    }
}
