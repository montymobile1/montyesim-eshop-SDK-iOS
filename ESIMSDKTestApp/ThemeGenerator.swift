//
//  ThemeGenerator.swift
//  SdkTestApp
//
//
//

import Foundation

struct ThemeGenerator {
    static func loadCustomTheme() -> AutoThemeConfig? {
        guard let url = Bundle.main.url(forResource: "theme", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let theme = try? JSONDecoder().decode(AutoThemeConfig.self, from: data) else {
            return nil
        }
        return theme
    }
}

struct AutoThemeConfig: Codable {
    let colors: AutoColors
    let typography: Typography
    let features: Features
}

struct AutoColors: Codable {
    let txtSubtitle: String
    let borderColor: String
    let disabledButtonColor: String
    let grayContainer: String
    let progressEmpty: String
    let appBackground: String
    let inputTextColor: String
    let primaryAppColor: String
    let buttonPrimaryColor: String
    let txtUnderlinedHighlight: String
    let buttonPrimaryVariantColor: String
    let bubblePrimaryColor: String
    let secondaryAppColor: String
    let titleColor: String
    let secondaryButtonColor: String
    let tabColor: String
    let secondaryGraphEmptyProgress: String
    let iconWarning: String
    let textWarning: String
    let txtColorError: String
    let iconColorError: String
    let borderError: String
    let iconErrorContainer: String
    let txtSuccess: String
    let iconSuccess: String
    let borderSuccess: String
    let iconSuccessContainer: String
}

struct Typography: Codable {
    let primaryFontFamily: String
    let secondaryFontFamily: String
}

struct Features: Codable {
    let darkMode: Bool
    let notifications: Bool
    let socialSharing: Bool
    let enableCruise: Bool
    let enablePromotion: Bool
    let enableMultiCurrency: Bool
    let enableFacebookLogin: Bool
    let enableAppleLogin: Bool
    let enableGoogleLogin: Bool
    let enableEmailLogin: Bool
    let enableWallet: Bool
    let enablePromoCode: Bool
    let enableGuestFlowBundlePurchase: Bool
}

