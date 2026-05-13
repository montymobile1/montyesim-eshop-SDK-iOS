# MontyESIM eShop SDK iOS - Sample App

A standalone iOS test project demonstrating integration of the **MontyESIM eShop SDK iOS** (`ESIMSDK.xcframework`).

## Overview

This project provides a minimal working example for integrating the MontyESIM eShop SDK into an iOS app. It covers SDK initialization, UI theming, social login (Google, Facebook, and Apple), Stripe payment processing, Firebase push notifications, deep linking, localization, and feature flag management. All libraries listed in the [Dependencies](#dependencies) section are mandatory for the SDK to compile and run correctly. Use it as a reference to get up and running quickly with the SDK in your own project.

## Requirements

- Xcode 14.0 or later
- Swift 5.9+
- iOS 16.0+ deployment target (iOS 13.0 minimum for the SDK package)
- **GoogleService-Info.plist** file from Firebase Console
- Apple Developer account (for push notifications and Sign in with Apple)

## Quick Start

### 1. Clone and Configure

```bash
git clone <your-repo-url>
cd B2CEsimSdkiOS
```

### 2. Set Up Required Credentials

Before building, you must replace all placeholder values with your own credentials:

| File | What to Replace |
|------|-----------------|
| `ESIMSDKTestApp/GoogleService-Info.plist` | Replace with your own file from [Firebase Console](https://console.firebase.google.com/) (see [Firebase Setup](#3-add-googleservice-infoplist)) |
| `ESIMSDKTestApp/AppDelegate.swift` | Replace `baseUrl` with your backend API URL |
| `ESIMSDKTestApp/AppDelegate.swift` | Replace `deepLinkUrl` with your app's deep link scheme |
| `ESIMSDKTestApp/AppDelegate.swift` | Replace `your-app-scheme://login-callback` with your Supabase OAuth redirect URI |
| `ESIMSDKTestApp/SdkTestApp.entitlements` | Verify capabilities match your provisioning profile |

> Search for `TODO` comments across the project to find all placeholders that need your values.

### 3. Add GoogleService-Info.plist

Replace the placeholder `GoogleService-Info.plist` in the `ESIMSDKTestApp/` directory with your real one:

```
ESIMSDKTestApp/GoogleService-Info.plist
```

Get this file from: **Firebase Console -> Project Settings -> Your apps -> Download `GoogleService-Info.plist`**.

The following fields must contain your real Firebase project values:

| Key | Description |
|-----|-------------|
| `CLIENT_ID` | Your iOS OAuth client ID from Google Cloud Console |
| `REVERSED_CLIENT_ID` | Reversed version of CLIENT_ID (used as URL scheme) |
| `API_KEY` | Your Firebase API key |
| `GCM_SENDER_ID` | Your Firebase Cloud Messaging sender ID |
| `BUNDLE_ID` | Your app's bundle identifier |
| `PROJECT_ID` | Your Firebase project ID |
| `STORAGE_BUCKET` | Your Firebase storage bucket URL |
| `GOOGLE_APP_ID` | Your Firebase app ID |

The project will not build correctly without a valid Firebase configuration.

### 4. Add the SDK

Add the SDK via **Xcode Swift Package Manager**:

1. Open your project in Xcode
2. Go to **File -> Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/montymobile1/montyesim-eshop-SDK-iOS.git
   ```
4. Select the version rule (e.g., **Up to Next Major Version**)
5. Add the `EsimKit` library to your target

### 5. Set Up Entitlements

Ensure the following capabilities are enabled in your Xcode project under **Signing & Capabilities**:

1. **Sign in with Apple** -- required for Apple authentication
2. **Push Notifications** -- required for Firebase Cloud Messaging

The entitlements file is located at:

```
ESIMSDKTestApp/SdkTestApp.entitlements
```

### 6. Configure Social Login

If you enable social login (Google/Facebook/Apple), you must configure each provider:

**Google Sign-In:**

1. Set up your project in [Google Cloud Console](https://console.cloud.google.com/)
2. Create an OAuth 2.0 client ID for iOS
3. Add the reversed client ID as a URL scheme in your Info.plist or Xcode target
4. The Google client ID is read from `GoogleService-Info.plist`

**Facebook Login:**

1. Set up your app in [Facebook Developer Console](https://developers.facebook.com/)
2. Configure the Facebook App ID and Client Token
3. Add required URL schemes and `LSApplicationQueriesSchemes` in Info.plist

**Apple Sign-In:**

1. Enable "Sign in with Apple" capability in Xcode
2. Configure the capability in your Apple Developer account provisioning profile
3. The implementation uses `ASAuthorizationAppleIDProvider` with nonce-based verification

**Supabase OAuth Integration:**

All social login tokens are exchanged for Supabase sessions. You must configure a custom URI scheme for the OAuth callback. Replace `your-app-scheme` and `login-callback` in `AppDelegate.swift` with your own values. This scheme must match your Supabase project's redirect URL configuration.

### 7. Build and Run

Open the project in Xcode:

```bash
open ESIMSDKTestApp.xcodeproj
```

Or build from the command line:

```bash
xcodebuild -project ESIMSDKTestApp.xcodeproj \
  -scheme ESIMSDKTestApp \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## Project Structure

```
├── Package.swift                              # SPM manifest (SDK binary target)
├── Sources/
│   ├── EsimKit/
│   │   └── EsimKit.swift                      # Public SDK wrapper (singleton)
│   └── Frameworks/
│       └── ESIMSDK.xcframework/               # Binary framework (arm64 + simulator)
├── ESIMSDKTestApp/                            # Test application
│   ├── SdkTestAppApp.swift                    # SwiftUI entry point, theme & feature flag UI
│   ├── AppDelegate.swift                      # App lifecycle, SDK init, push & social login
│   ├── ContentView.swift                      # Main coordinator, Stripe & social login managers
│   ├── StripePaymentHandler.swift             # Stripe PaymentSheet integration
│   ├── ThemeConfigurations.swift              # Blue, Purple, and Automatic theme definitions
│   ├── ThemeGenerator.swift                   # Dynamic theme loading from theme.json
│   ├── SDKTestLocalizationProvider.swift      # Multi-language localization provider
│   ├── SecurityExtensions.swift               # Nonce generation & SHA256 utilities
│   ├── GoogleService-Info.plist               # Firebase config (replace with yours)
│   ├── SdkTestApp.entitlements                # App capabilities (Apple Sign-In, Push)
│   ├── Assets.xcassets/                       # Image assets
│   └── Localizable.xcstrings                  # String catalog (en, ar, fr)
├── ESIMSDKTestApp.xcodeproj/                  # Xcode project
└── ESIMSDK.xcframework.zip                    # Packaged SDK for SPM distribution
```

## SDK Configuration

The SDK is initialized in `AppDelegate.swift` inside `application(_:didFinishLaunchingWithOptions:)`:

```swift
ESIMCore.setupSDK(
    baseUrl: "https://your-api-domain.com",           // TODO: Replace with your API URL
    userConfigs: ESimUserConfigs(
        deepLinkUrl: "your-deeplink-scheme://",       // TODO: Replace with your deep link URL
        countryCode: ESimFPNCountryCode.LB
    ),
    localizationProvider: SDKTestLocalizationProvider(),
    paymentDelegate: self,
    socialLoginDelegate: self,
    supaBaseDelegate: self,
    loggedOutDelegate: self
)
```

### Configuration Parameters

| Setting | Placeholder | Description |
|---------|-------------|-------------|
| `baseUrl` | `https://your-api-domain.com` | Your backend API URL |
| `deepLinkUrl` | `your-deeplink-scheme://` | Your app's deep link scheme |
| `countryCode` | `ESimFPNCountryCode.LB` | Default phone region (Lebanon) |
| `localizationProvider` | `SDKTestLocalizationProvider()` | Custom localization delegate |
| `paymentDelegate` | `self` (AppDelegate) | Handles Stripe payment events |
| `socialLoginDelegate` | `self` (AppDelegate) | Handles Google, Facebook, Apple login |
| `supaBaseDelegate` | `self` (AppDelegate) | Handles OAuth token exchange |

### Feature Flags

Feature flags are managed via `ESimFeatureFlagManager.shared` and can be toggled in the app's configuration UI on launch:

| Feature | Description |
|---------|-------------|
| Facebook Login | Enable Facebook authentication |
| Apple Login | Enable Apple Sign-In |
| Google Login | Enable Google authentication |
| Email Login | Enable email-based authentication |
| Cruise Mode | Enable cruise mode features |
| Promotions | Enable promotional content |
| Multi-Currency | Enable currency selection |
| Wallet | Enable wallet view |
| Promo Code | Enable promo code entry |
| Guest Purchase | Enable guest bundle purchase flow |

### Theming

Three built-in theme variants are available in `ThemeConfigurations.swift`:

| Theme | Description |
|-------|-------------|
| Blue | Blue primary with dark secondary |
| Purple | Default SDK purple theme |
| Automatic | Dynamic theme loaded from `theme.json` |

Custom themes can be defined programmatically using `ESimTheme` with:
- `ESimColors` -- primary, secondary, tertiary, button, status, and container colors
- `ESimTypography.custom(primaryFontFamily:, secondaryFontFamily:)` -- custom fonts
- `ESimShapes.default` -- default shape system

### Localization

The app supports multiple languages via `SDKTestLocalizationProvider`:

| Language | Code |
|----------|------|
| English | `en` |
| Arabic | `ar` |
| French | `fr` |

Translations are stored in `Localizable.xcstrings` (Xcode String Catalog format). The provider implements `ESimLocalizationProvider` and loads translations using `NSLocalizedString` with fallback to the key.

## Key Integrations

### Social Login

Social login is handled via three manager classes in `ContentView.swift`, each conforming to `SocialMediaLoginManager`:

| Provider | Manager Class | Framework |
|----------|--------------|-----------|
| Google | `GoogleLoginManager` | GoogleSignIn |
| Facebook | `FacebookLoginManager` | FBSDKLoginKit |
| Apple | `AppleLoginManager` | AuthenticationServices |

All providers exchange their tokens with Supabase for session management.

### Payments (Stripe)

Stripe integration uses `StripePaymentSheet` with the following flow:

1. SDK triggers payment via `ESimPaymentDelegate` (`didAssignedBundle` or `startTopUpWallet`)
2. App receives Stripe configuration (publishable key, customer ID, ephemeral key, client secret)
3. `PaymentSheet` is configured and presented
4. Payment result (`.completed`, `.canceled`, `.failed`) is forwarded back to the SDK via `paymentManager`

Implementation files:
- `StripePaymentHandler.swift` -- PaymentSheet observer and state management
- `ContentView.swift` -- PaymentSheet presentation and result handling

### Push Notifications (Firebase Cloud Messaging)

Push notifications are configured in `AppDelegate.swift`:

1. `FirebaseApp.configure()` initializes Firebase
2. FCM delegate is set for token management
3. User authorization is requested (alert, badge, sound)
4. Device tokens are forwarded from APNS to Firebase
5. FCM tokens are stored in `UserDefaults` under key `"fcmToken"`
6. Incoming notifications are routed through `DeepLinkCoordinator`

> **Note:** You must implement token-to-backend forwarding (see `TODO` in `AppDelegate.swift`).

### Deep Linking

Deep links are handled via `DeepLinkCoordinator`:
- Instantiated in `AppDelegate.swift`
- Attached to the SwiftUI view hierarchy via `.handleDeepLinks(coordinator:)`
- Push notification payloads are routed through the coordinator

## Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| ESIMSDK | XCFramework (binary) | Core eSIM SDK |
| Swift | 5.9+ | Language version |
| Stripe | 25.9.0 | Payment processing |
| GoogleSignIn | 9.1.0 | Google authentication |
| Supabase | 2.43.0 | Backend auth & database |
| Facebook SDK | 14.1.0 | Facebook login |
| Firebase Core | 12.11.0 | Firebase foundation |
| Firebase Messaging | 12.11.0 | Push notifications (FCM) |
| SwiftUI | Native | UI framework |
| AuthenticationServices | Native | Apple Sign-In |

All dependencies are managed via Swift Package Manager.

## Credentials & Sensitive Information Checklist

Before publishing or sharing this project, ensure the following files contain **only placeholder values** and not real credentials:

| File | What to Verify |
|------|---------------|
| `ESIMSDKTestApp/GoogleService-Info.plist` | All Firebase keys are placeholders (`YOUR_*`) |
| `ESIMSDKTestApp/AppDelegate.swift` | `baseUrl` and `deepLinkUrl` are placeholders |
| `ESIMSDKTestApp/AppDelegate.swift` | Supabase OAuth redirect URI is a placeholder |

Add your real `GoogleService-Info.plist` to `.gitignore` if working in a shared repository:

```gitignore
ESIMSDKTestApp/GoogleService-Info.plist
```

### Push Notifications

Send a test notification via Firebase Console to verify the integration.

### Deep Links

Test deep links using the terminal:

```bash
xcrun simctl openurl booted "your-deeplink-scheme://path"
```

## Troubleshooting

### Build fails -- missing or invalid GoogleService-Info.plist

Download your `GoogleService-Info.plist` from Firebase Console and place it in `ESIMSDKTestApp/GoogleService-Info.plist`.

### SPM package resolution fails

1. In Xcode: **File -> Packages -> Reset Package Caches**
2. Then: **File -> Packages -> Resolve Package Versions**
3. Verify your network can reach the GitHub repository hosting the SDK

### ESIMSDK.xcframework not found

If using the local binary target, verify `ESIMSDK.xcframework` exists in `Sources/Frameworks/` and that `Package.swift` points to the correct path.

### Sign in with Apple not working

1. Verify the **Sign in with Apple** capability is enabled in Xcode under **Signing & Capabilities**
2. Ensure your provisioning profile includes this capability
3. Check that `SdkTestApp.entitlements` contains `com.apple.developer.applesignin`

### Push notifications not received

1. Verify the **Push Notifications** capability is enabled in Xcode
2. Ensure `aps-environment` is set in entitlements (use `development` for debug, `production` for release)
3. Confirm `GoogleService-Info.plist` has the correct GCM Sender ID
4. Upload your APNS certificate or key to Firebase Console

### Placeholder values not replaced

Search for `TODO` comments in the codebase to find all placeholders that need to be replaced with your real credentials and URLs.

### Stripe payment sheet not appearing

1. Verify the SDK is returning valid Stripe configuration data
2. Ensure the `StripePaymentSheet` SPM package is properly linked to your target
3. Check the Xcode console for Stripe-related errors

## Architecture

The test app uses a **SwiftUI + UIApplicationDelegate hybrid** architecture:

- **`SdkTestAppApp`** (`@main`) -- SwiftUI app entry point with `@UIApplicationDelegateAdaptor`
- **`AppDelegate`** -- Handles SDK initialization, Firebase setup, push notifications, and social login delegation
- **`ContentView`** -- Coordinates the SDK UI (`ESimAppCoordinatorView`), Stripe payment sheets, and social login managers
- **Delegate Pattern** -- `AppDelegate` conforms to `ESimPaymentDelegate`, `ESimSocialLoginDelegate`, `ESimSupaBaseDelegate`, and `ESimLoggedOutDelegate`
- **Environment Objects** -- `ThemeManager`, `ESimFeatureFlagManager`, and `PaymentManager` are injected via SwiftUI environment

## Documentation

See the inline code comments and this README for integration guidance.
