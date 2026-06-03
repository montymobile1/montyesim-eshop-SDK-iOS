//
//  AppDelegate.swift
//  SdkTestApp
//
//
//

import UIKit
import ESIMSDK
import SwiftUI
import Supabase
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    
    public var deepLinkCoordinator : ESIMDeepLinkCoordinator?
    
    var client: SupabaseClient!
    let apple = AppleLoginManager()
    let google = GoogleLoginManager()
    let faceBook = FacebookLoginManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Configure Firebase (requires valid GoogleService-Info.plist)
        // TODO: Download GoogleService-Info.plist from Firebase Console before enabling
         FirebaseApp.configure()

        // Set up Firebase Messaging
         Messaging.messaging().delegate = self

        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // TODO: Replace with your backend API URL and deep link URL
        ESIMCore.setupSDK(
            baseUrl: "https://your-api-domain.com",
            userConfigs: ESimUserConfigs(
                deepLinkUrl: "your-deeplink-scheme:/",
                countryCode: ESimFPNCountryCode.LB
            ),
            paymentDelegate: self,
            socialLoginDelegate: self,
            supaBaseDelegate: self,
            loggedOutDelegate: self
        )
        
        deepLinkCoordinator = ESIMDeepLinkCoordinator()
        
        /// Create a single supabase client for interacting with your database
        
        return true
    }
    
    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for remote notifications")
        // Pass device token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}

extension AppDelegate: ESimPaymentDelegate {
    func startTopUpWallet(with data: ESIMSDK.ESimBundleAssignmentDomain?, paymentManager: ESIMSDK.ESimPaymentManager?) {
        print("startTopUpWallet \(data)")
    }
    
    func didAssignedBundle(
        with data: ESIMSDK.ESimBundleAssignmentDomain,
        paymentManager: ESIMSDK.ESimPaymentManager?) {
            print("Payment DidStart Data \(data)")
    }
}

extension AppDelegate: ESimLogoutDelegate {
    func didLoggedOut() {
        print("did Logged Out")
    }
}


extension AppDelegate: ESimSocialLoginDelegate {
    func continueWithFacebook() {
        print("continueWithFacebook")
        faceBookSignIn()
    }
    
    func continueWithApple() {
        print("continueWithApple")
        appleSignIn()
    }
    
    func continueWithGoogle() {
        print("continueWithGoogle")
        googleSignIn()
    }
}


extension AppDelegate {
    func appleSignIn() {
        apple.login() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                Task {
                    do {
                        try await self.verifySocialLogin(result: response, platform: .apple)
                    } catch {
                        print("Apple sign-in error: \(error)")
                        await MainActor.run {
                            // Optionally show an alert or toast here
                        }
                    }
                }
            case .failure(let error):
                print("Apple login failed: \(error)")
            }
        }
    }
    
    func googleSignIn() {
        google.login() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                Task {
                    do {
                        try await self.verifySocialLogin(result: response, platform: .google)
                    } catch {
                        print("Google sign-in error: \(error)")
                        await MainActor.run { }
                    }
                }
            case .failure(let error):
                print("Google login failed: \(error)")
            }
        }
    }
    
    func faceBookSignIn()  {
        Task {
            do {
                try await self.verifySocialLogin(
                    result: SocialLoginResult(),
                    platform: .facebook
                )
                
            } catch {
                print("Facebook login error: \(error)")
            }
        }
    }
    
    private func verifySocialLogin(
        result: SocialLoginResult,
        platform: SocialPlatform) async throws {
            #if DEBUG
            print("verifySocialLogin for \(platform.rawValue)")
            #endif
            switch platform {
            case .facebook:
                do {
                    // Use the signInWithOAuth method with provider
                    // TODO: Replace with your Supabase OAuth redirect URI
                    try await client.auth.signInWithOAuth(
                        provider: .facebook,
                        redirectTo: URL(
                            string: "iosupabaseflutter://login-callback"
                        )
                    )
                    // The SDK automatically handles the OAuth flow and session management
                    // After successful authentication, the session will be available

                    let session = try await client.auth.session
                    #if DEBUG
                    print("Successfully logged in! User ID: \(session.user.id)")
                    #endif
                    await MainActor.run {
                        ESIMCore.shared.authProvider.sessionChanged(
                            ESimSession(
                                accessToken: session.accessToken,
                                refreshToken: session.refreshToken
                            )
                        )
                    }
                } catch {
                    print("Facebook login error: \(error)")
                }
            case .google:
                let session = try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .google,
                        idToken: result.googleIdToken,
                        accessToken: result.googleAccessToken
                    )
                )
                #if DEBUG
                print("SupaBase google signIn session: \(session)")
                #endif
                await MainActor.run {
                    ESIMCore.shared.authProvider.sessionChanged(
                        ESimSession(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken,
                        )
                    )
                }
                
            case .apple:
                let session = try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: result.appleToken,
                        nonce: result.nonce,
                    )
                )
                #if DEBUG
                print("SupaBase Apple signIn session: \(session)")
                #endif
                await MainActor.run {
                    ESIMCore.shared.authProvider.sessionChanged(
                        ESimSession(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    )
                }
            case .email:
                break
            }
        }
}

extension AppDelegate: ESimSupabaseConfigDelegate {
    func loaded(with configs: ESIMSDK.ESIMSupaBaseConfigs) {
        print("didFetch supaBase config \(configs)")
        client = SupabaseClient(
            supabaseURL: URL(string: configs.supabaseURLString)!,
            supabaseKey: configs.supabaseKey,
            options: .init(
                auth: .init(
                    autoRefreshToken: true,
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}

// MARK: - Firebase Messaging Delegate
extension AppDelegate: MessagingDelegate {
    
    // Called when FCM token is refreshed
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("Firebase FCM Token refreshed")
        #endif
        
        // Store the token securely in Keychain
        if let token = fcmToken {
            KeychainHelper.save(token, forKey: "fcmToken")

            // Post notification for UI updates if needed
            NotificationCenter.default.post(
                name: Notification.Name("FCMTokenRefreshed"),
                object: nil,
                userInfo: ["token": token]
            )

            // TODO: Send this token to your backend server
            // sendTokenToServer(token)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    //  user tap on the notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with data: \(userInfo)")
        
        deepLinkCoordinator?.handleNotification(userInfo, { handled in
            if handled {
                print("Link Handled")
            } else {
                print("Link Not Handled")
            }
        })
        completionHandler()
    }
    
    // foreground Notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification received in foreground: \(userInfo)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    // background Notification
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        deepLinkCoordinator?.handleNotification(userInfo, { handled in
            if handled {
                print("Link Handled")
            } else {
                print("Link Not Handled")
            }
        })
        completionHandler(.newData)
    }
}
