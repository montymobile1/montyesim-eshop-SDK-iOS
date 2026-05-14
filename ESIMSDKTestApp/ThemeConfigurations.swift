//
//  ThemeConfigurations.swift
//  SdkTestApp
//
//
//

import Foundation
import SwiftUI
import ESIMSDK

struct ThemeConfigurations {
    // Theme Configuration 1 -  Automatic Theme (loaded from theme.json)
    static var automatic: ESimTheme {
        guard let theme = ThemeGenerator.loadCustomTheme() else {
            return  ESimTheme(
                colors: ESimClientColorScheme.defaultColor,
                typography: ESimTypography.defaultTypography,
                shapes: ESimShapes.defaultShapes
            )
        }
        
        let configs  =  ESimTheme(
            colors: ESimClientColorScheme(
                txtSubtitle: Color(hex: theme.colors.txtSubtitle), // gray600
                borderColor: Color(hex: theme.colors.borderColor), // gray200
                disabledButtonColor: Color(hex: theme.colors.disabledButtonColor), // gray200
                grayContainer: Color(hex: theme.colors.grayContainer), // gray100
                progressEmpty: Color(hex:theme.colors.progressEmpty), // gray100
                appBackground: Color(hex: theme.colors.appBackground), // gray25
                inputTextColor: Color(hex: theme.colors.inputTextColor), // primary900
                primaryAppColor: Color(hex: theme.colors.primaryAppColor), // primary800
                buttonPrimaryColor: Color(hex: theme.colors.buttonPrimaryColor), // primary800
                txtUnderlinedHighlight: Color(hex: theme.colors.txtUnderlinedHighlight), // primary500
                buttonPrimaryVariantColor: Color(hex: theme.colors.buttonPrimaryVariantColor), // primary500
                bubblePrimaryColor: Color(hex: theme.colors.bubblePrimaryColor), // primary25
                secondaryAppColor: Color(hex: theme.colors.secondaryAppColor), // secondary600
                titleColor: Color(hex: theme.colors.titleColor), // secondary600
                secondaryButtonColor: Color(hex: theme.colors.secondaryButtonColor), // secondary600
                tabColor: Color(hex: theme.colors.tabColor), // secondary600
                secondaryGraphEmptyProgress: Color(hex: theme.colors.secondaryGraphEmptyProgress), // secondary300
                iconWarning: Color(hex: theme.colors.iconWarning),
                textWarning: Color(hex: theme.colors.textWarning), // warning50
                txtColorError: Color(hex: theme.colors.txtColorError), // error500
                iconColorError: Color(hex: theme.colors.iconColorError), // error500
                borderError: Color(hex: theme.colors.borderError), // error300
                iconErrorContainer: Color(hex: theme.colors.iconErrorContainer), // error50
                txtSuccess: Color(hex: theme.colors.txtSuccess), // success700
                iconSuccess: Color(hex: theme.colors.iconSuccess), // success700
                borderSuccess: Color(hex: theme.colors.borderSuccess), // success400
                iconSuccessContainer: Color(hex: theme.colors.iconSuccessContainer) // success50
            ),
            typography: ESimTypography.custom(
                primaryFontFamily: theme.typography.primaryFontFamily,
                secondaryFontFamily: theme.typography.secondaryFontFamily
            ),
            shapes: ESimShapes.defaultShapes
        )
        ESimFeatureFlagManager.shared.enableCruise = theme.features.enableCruise
        ESimFeatureFlagManager.shared.enableWallet = theme.features.enableWallet
        ESimFeatureFlagManager.shared.enablePromotion = theme.features.enablePromotion
        ESimFeatureFlagManager.shared.enablePromoCode = theme.features.enablePromoCode
        ESimFeatureFlagManager.shared.enableAppleLogin = theme.features.enableAppleLogin
        ESimFeatureFlagManager.shared.enableEmailLogin = theme.features.enableEmailLogin
        ESimFeatureFlagManager.shared.enableGoogleLogin = theme.features.enableGoogleLogin
        ESimFeatureFlagManager.shared.enableFaceBookLogin = theme.features.enableFacebookLogin
        ESimFeatureFlagManager.shared.enableMultiCurrnecy = theme.features.enableMultiCurrency
        ESimFeatureFlagManager.shared.enableguestFlowBundlePurchase = theme.features.enableGuestFlowBundlePurchase
        return configs
    }
    
    // Theme Configuration 2 -  Blue Theme
    static var blueTheme: ESimTheme {
        ESimTheme(
            colors: ESimClientColorScheme(
                txtSubtitle: Color(hex: "#475467"), // gray600
                borderColor: Color(hex: "#EAECF0"), // gray200
                disabledButtonColor: Color(hex: "#EAECF0"), // gray200
                grayContainer: Color(hex: "#F2F4F7"), // gray100
                progressEmpty: Color(hex: "#F2F4F7"), // gray100
                appBackground: Color(hex: "#FCFCFD"), // gray25
                inputTextColor: Color(hex: "#2C507C"), // primary900
                primaryAppColor: Color(hex: "#3478CA"), // primary800
                buttonPrimaryColor: Color(hex: "#3478CA"), // primary800
                txtUnderlinedHighlight: Color(hex: "#122644"), // primary500
                buttonPrimaryVariantColor: Color(hex: "#122644"), // primary500
                bubblePrimaryColor: Color(hex: "#EAF3FD"), // primary25
                secondaryAppColor: Color(hex: "#0D1025"), // secondary600
                titleColor: Color(hex: "#0D1025"), // secondary600
                secondaryButtonColor: Color(hex: "#0D1025"), // secondary600
                tabColor: Color(hex: "#0D1025"), // secondary600
                secondaryGraphEmptyProgress: Color(hex: "#F1ECE7"), // secondary300
                iconWarning: Color(hex: "#FFFAEB"),
                textWarning: Color(hex: "#B54708"), // warning50
                txtColorError: Color(hex: "#F04438"), // error500
                iconColorError: Color(hex: "#F04438"), // error500
                borderError: Color(hex: "#FDA29B"), // error300
                iconErrorContainer: Color(hex: "#FEF3F2"), // error50
                txtSuccess: Color(hex: "#027A48"), // success700
                iconSuccess: Color(hex: "#027A48"), // success700
                borderSuccess: Color(hex: "#79A528"), // success400
                iconSuccessContainer: Color(hex: "#ECFDF3") // success50
            ),
            typography: ESimTypography.custom(
                primaryFontFamily: "Poppins",
                secondaryFontFamily: "Poppins"
            ),
            shapes: ESimShapes.defaultShapes
        )
    }
    
    // Theme Configuration 3 - Purple Theme
    static var purpleTheme: ESimTheme {
        ESimTheme(
            colors: ESimClientColorScheme.defaultColor,
            typography: ESimTypography.defaultTypography,
            shapes: ESimShapes.defaultShapes
        )
    }
}

enum AppThemeVariant: String, CaseIterable {
    case blue = "Blue Theme"
    case purple = "Purple Theme"
    case custom = "Automatic"
    
    var theme: ESimTheme {
        switch self {
        case .blue:
            return ThemeConfigurations.blueTheme
        case .purple:
            return ThemeConfigurations.purpleTheme
        case .custom:
            return ThemeConfigurations.automatic
        }
    }
}
