// PaymentViewModel.swift

import Foundation
import Stripe
import FirebaseAuth
import FirebaseFirestore

class PaymentViewModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var errorMessage: String? = nil
    
    func preparePayment(from viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not authenticated."
            completion(.failure(NSError(domain: "Authentication", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }
        
        // Fetch PaymentIntent and Customer details from your backend
        // This is a placeholder function. Implement your own network call here.
        fetchPaymentIntent { result in
            switch result {
            case .success(let paymentIntentClientSecret):
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "AutoShare"
                // Add additional configuration if needed
                
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                completion(.success(()))
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }
    
    func presentPaymentSheet(from viewController: UIViewController) {
        guard let paymentSheet = paymentSheet else {
            print("PaymentSheet is not prepared.")
            return
        }
        
        paymentSheet.present(from: viewController) { result in
            self.paymentResult = result
            switch result {
            case .completed:
                print("Payment completed successfully.")
                // Handle successful payment (e.g., update booking status)
            case .canceled:
                print("Payment canceled.")
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
            // Optionally, notify observers or update UI accordingly
        }
    }
    
    // Placeholder function to fetch PaymentIntent client secret
    func fetchPaymentIntent(completion: @escaping (Result<String, Error>) -> Void) {
        // Implement your network request to your backend server to create a PaymentIntent
        // and return the client secret.
        // For demonstration, we'll return a dummy client secret after a delay.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Replace this with actual client secret from your backend
            let dummyClientSecret = "pi_XXXXXXXXXXXXXXXX_secret_XXXXXXXXXXXXXXXX"
            completion(.success(dummyClientSecret))
        }
    }
}
