//
//  StripePaymentHandler.swift
//  SdkTestApp
//
//
//

import Combine
import StripePaymentSheet
import SwiftUI
import ESIMSDK

class StripePaymentHandler: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    
    @MainActor func onPaymentCompletion(result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("onPaymentCompletion: completed")
            ESIMCore.shared.paymentManager.paymentResult = .success
        case .canceled:
            print("canceled")
            ESIMCore.shared.paymentManager.paymentResult = .cancelled
        case .failed(let error):
            ESIMCore.shared.paymentManager.paymentResult = .failed(error: error.localizedDescription)
            print("failed")
        }
    }
}

