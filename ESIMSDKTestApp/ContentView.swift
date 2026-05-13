//
//  ContentView.swift
//  SdkTestApp
//
//
//

import SwiftUI
import ESIMSDK
import Stripe
import StripePaymentSheet
import GoogleSignIn
import GoogleSignInSwift
import Supabase
import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var paymentManager: ESimPaymentManager
    @StateObject var model = StripePaymentHandler()
    @State var showSheet = false
    @State private var orderData: ESimOrderLoadingDomain?
    @State private var showMyESimOrderBy: Bool = false
    @State private var showPaymentSuccess: Bool = false
    @State var showStripe = false
    
    var body: some View {
        ESimAppCoordinatorView()
            .preferredColorScheme(.light)
            .paymentSheet(
                isPresented: $showSheet,
                paymentSheet: model.paymentSheet ?? PaymentSheet(
                    paymentIntentClientSecret: "",
                    configuration: PaymentSheet.Configuration()
                )
            ) { result in
                model.onPaymentCompletion(result: result)
            }
            .onChange(of: paymentManager.stripeSheetData) { payData in
                guard let payData else { return }
                #if DEBUG
                print("Stripe payment data received")
                #endif
                
                // Dismiss any existing sheet first
                if showSheet {
                    showSheet = false
                }
                
                STPAPIClient.shared.publishableKey = payData.publishableKey
                
                var configuration = PaymentSheet.Configuration()
                
                configuration.merchantDisplayName = payData.merchantDisplayName ?? "N/A"
                configuration.customer = .init(
                    id: payData.customerId ?? "",
                    ephemeralKeySecret: payData.customerEphemeralKeySecret ?? ""
                )
                model.paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: payData.paymentIntentClientSecret ?? "",
                    configuration: configuration
                )
                
                // Add a small delay to ensure previous sheet is dismissed
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1))
                    showSheet = true
                }
            }
            .background(.white)
            .environment(\.layoutDirection, themeManager.rightToLeft ? .rightToLeft : .leftToRight)
            .environment(\.locale, themeManager.locale)
    }
    
    @ViewBuilder
    var payButton: some View {
        HStack {
            Spacer()
            Text("Pay")
            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.indigo)
        )
    }
    
#if canImport(UIKit)
    var root: UIViewController {
        UIApplication.shared.firstKeyWindow?.rootViewController ?? UIViewController()
    }
#else
    var root: NSWindow {
        NSApplication.shared.keyWindow ?? NSWindow()
    }
#endif
}

protocol SocialMediaLoginManager {
    func login(completion: @escaping (Result<SocialLoginResult, Error>) -> Void)
}

class GoogleLoginManager: SocialMediaLoginManager {
    func login(completion: @escaping (Result<SocialLoginResult, Error>) -> Void) {
        guard let topVC = UIApplication.getTopViewController() else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let signInResult = signInResult else {
                completion(.failure(GoogleLoginError.notData))
                return
            }
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            let idToken = user.idToken?.tokenString ?? ""
            #if DEBUG
            print("Google sign-in successful")
            #endif
            let result = SocialLoginResult(
                googleToken: accessToken,
                googleIdToken: idToken
            )
            completion(.success(result))
        }
    }
}

class FacebookLoginManager: SocialMediaLoginManager {
    func login(completion: @escaping (Result<SocialLoginResult, Error>) -> Void) {
        guard let topVC = UIApplication.getTopViewController() else { return }
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: topVC) { (result, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let result = result, !result.isCancelled else {
                print("User cancelled login.")
                completion(.failure(FacebookLoginError.userCancelled))
                return
            }
            
            if let accessToken = result.token?.tokenString {
                #if DEBUG
                print("Facebook sign-in successful")
                #endif
                let result = SocialLoginResult(facebookToken: accessToken)
                completion(.success(result))
            } else {
                completion(.failure(FacebookLoginError.noAccessToken))
            }
        }
    }
}

class AppleLoginManager: NSObject, SocialMediaLoginManager {
    private var completion: ((Result<SocialLoginResult, Error>) -> Void)?
    private var currentNonce: String = ""
    
    func login(completion: @escaping (Result<SocialLoginResult, Error>) -> Void) {
        self.currentNonce = String.randomNonce()
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = self.currentNonce.sha256

        let authorizationController = ASAuthorizationController(
            authorizationRequests: [request]
        )
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        self.completion = completion
    }
}

#if canImport(UIKit)
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = UIApplication.shared.firstKeyWindow { return window }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first
            ?? UIWindow()
    }
}
#endif

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let authorizationToken = appleIDCredential.identityToken {
            guard let authorizationTokenString = String(data: authorizationToken, encoding: .utf8) else {
                completion?(.failure(GoogleLoginError.notData))
                return
            }
            #if DEBUG
            print("Apple sign-in successful")
            #endif
            let result = SocialLoginResult(appleToken: authorizationTokenString,nonce: currentNonce)
            completion?(.success(result))
        } else {
            completion?(.failure(GoogleLoginError.notData))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

enum GoogleLoginError: Error {
    case notData
}

enum FacebookLoginError: Error {
    case userCancelled
    case noAccessToken
}

enum SocialPlatform: String {
    case facebook
    case google
    case apple
    case email
}

#if canImport(UIKit)
import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
#endif

struct SocialLoginResult {
    let name: String
    let email: String
    let facebookToken: String
    let googleAccessToken: String
    let googleIdToken: String
    let appleToken: String
    let otp: String
    let nonce: String
    
    init(
        name: String = "",
        email: String = "",
        facebookToken: String = "",
        googleToken: String = "",
        googleIdToken: String = "",
        appleToken: String = "",
        otp: String = "",
        nonce: String = "",
    ) {
        self.name = name
        self.email = email
        self.facebookToken = facebookToken
        self.googleAccessToken = googleToken
        self.googleIdToken = googleIdToken
        self.appleToken = appleToken
        self.otp = otp
        self.nonce = nonce
    }
}

extension UIApplication {
    class func getTopViewController(
        base: UIViewController? = UIApplication.shared.firstKeyWindow?.rootViewController ?? UIViewController()
    ) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

