//
//  PaymentViewModel.swift
//  AutoShare
//

import Foundation
import StripePaymentSheet
import Combine
import UIKit // Added this to resolve the UIViewController error

class PaymentViewModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    
    /// Prepares the PaymentSheet with customerID, ephemeralKeySecret, and paymentIntentClientSecret
    func preparePaymentSheet(customerID: String, ephemeralKeySecret: String, paymentIntentClientSecret: String) {
        var configuration = PaymentSheet.Configuration() // Changed to `var` to allow mutation
        configuration.merchantDisplayName = "Your Merchant Name"
        
        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
    }
    
    /// Presents the PaymentSheet to handle the payment flow
    func presentPaymentSheet(from viewController: UIViewController) {
        guard let paymentSheet = paymentSheet else { return }
        paymentSheet.present(from: viewController) { paymentResult in
            switch paymentResult {
            case .completed:
                print("Payment complete")
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
            case .canceled:
                print("Payment canceled")
            }
        }
    }
}
