
//
//  SdkTestAppApp.swift
//  SdkTestApp
//
//
//

import SwiftUI
import ESIMSDK

@main
struct SdkTestAppApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var configsUpdated = false
    
    var body: some Scene {
        WindowGroup {
            contentView
                .preferredColorScheme(.light)
                .environmentObject(ESimFeatureFlagManager.shared)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        mainFlowView
    }

    @ViewBuilder
    private var mainFlowView: some View {
        VStack {
            if configsUpdated {
                ThemeSelectionView(deepLinkCoordinator: appDelegate.deepLinkCoordinator)
            } else {
                FeatureFlagsView(
                    configsUpdated: $configsUpdated
                )
            }
        }
    }
}

// MARK: - Theme Selection

struct ThemeSelectionView: View {
    let deepLinkCoordinator: DeepLinkCoordinator
    @State var selectedTheme: AppThemeVariant = .blue
    @State private var showingApp = false
    
    var body: some View {
        if showingApp {
            ContentView()
                .environmentObject(
                    ThemeManager(
                        initialTheme: selectedTheme.theme,
                        localization: ESimLocalizationManager(
                            supportedLanguages: [ESimLanguage.english, ESimLanguage.arabic, ESimLanguage.french]
                        ),
//                        imageProvider: ESimImageProvider(defaultCompany: Image(.companyLogo))
                    )
                )
                .environmentObject(ESimFeatureFlagManager.shared)
                .environmentObject(ESIMCore.shared.paymentManager)
                .environmentObject(ESIMCore.shared.authProvider)
                .handleDeepLinks(coordinator: deepLinkCoordinator)
        } else {
            VStack(spacing: 30) {
                Text("Select App Theme")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    ForEach(AppThemeVariant.allCases, id: \.self) { theme in
                        Button(action: {
                            selectedTheme = theme
                            showingApp = true
                        }) {
                            HStack {
                                Circle()
                                    .fill(getThemePreviewColor(for: theme))
                                    .frame(width: 20, height: 20)
                                
                                Text(theme.rawValue)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedTheme == theme ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                if selectedTheme != .blue {
                    Button("Launch App with \(selectedTheme.rawValue)") {
                        showingApp = true
                    }
                    .padding()
                    .background(getThemePreviewColor(for: selectedTheme))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func getThemePreviewColor(for theme: AppThemeVariant) -> Color {
        switch theme {
        case .blue:
            return Color(hex: "#0056D2")
        case .purple:
            return Color(hex: "#6B207D")
        case .custom:
            return Color.primary
        }
    }
}

// MARK: - Feature Flags

struct FeatureFlagsView: View {
    @EnvironmentObject var featureFlags: ESimFeatureFlagManager
    @Binding var configsUpdated: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Authentication")) {
                    FeatureFlagRow(
                        title: "Facebook Login",
                        isEnabled: $featureFlags.enableFaceBookLogin
                    )
                    
                    FeatureFlagRow(
                        title: "Apple Login",
                        isEnabled: $featureFlags.enableAppleLogin
                    )
                    
                    FeatureFlagRow(
                        title: "Google Login",
                        isEnabled: $featureFlags.enableGoogleLogin
                    )
                    
                    FeatureFlagRow(
                        title: "Email Login",
                        isEnabled: $featureFlags.enableEmailLogin
                    )
                }
                
                Section(header: Text("Core Features")) {
                    FeatureFlagRow(
                        title: "Cruise",
                        isEnabled: $featureFlags.enableCruise
                    )
                    
                    FeatureFlagRow(
                        title: "Promotion",
                        isEnabled: $featureFlags.enablePromotion
                    )
                    
                    FeatureFlagRow(
                        title: "Multi Currency",
                        isEnabled: $featureFlags.enableMultiCurrnecy
                    )
                    
                    FeatureFlagRow(
                        title: "Wallet",
                        isEnabled: $featureFlags.enableWallet
                    )
                    
                    FeatureFlagRow(
                        title: "Promo Code",
                        isEnabled: $featureFlags.enablePromoCode
                    )
                }
                
                Section(header: Text("Purchase Features")) {
                    FeatureFlagRow(
                        title: "Guest Flow Bundle Purchase",
                        isEnabled: $featureFlags.enableguestFlowBundlePurchase
                    )
                }
                Section {
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
                Section {
                    Button("Continue") {
                        configsUpdated = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Feature Flags")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func resetToDefaults() {
        featureFlags.enableCruise = true
        featureFlags.enablePromotion = true
        featureFlags.enableMultiCurrnecy = false
        featureFlags.enableFaceBookLogin = true
        featureFlags.enableAppleLogin = true
        featureFlags.enableGoogleLogin = true
        featureFlags.enableEmailLogin = true
        featureFlags.enableWallet = true
        featureFlags.enablePromoCode = true
        featureFlags.enableguestFlowBundlePurchase = true
    }
}

struct FeatureFlagRow: View {
    let title: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEnabled.toggle()
        }
    }
}
