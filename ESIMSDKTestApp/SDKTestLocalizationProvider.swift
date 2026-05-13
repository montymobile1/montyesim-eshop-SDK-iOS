//
//  SDKTestLocalizationProvider.swift
//  SdkTestApp
//
//
//

import ESIMSDK

public class SDKTestLocalizationProvider: ESimLocalizationProvider {

    public init() {
        // debugBundleContents() can be enabled for debugging if needed.
    }

    public func localizedString(for key: String) -> String {
        let languageCode = ESimAppSettings.selectedLanguage?.languageCode ?? "en"
        // Get the language-specific bundle
        let localized = localizedString(for: key, languageCode: languageCode)
        return localized
    }
    
    private func localizedString(for key: String, languageCode: String) -> String {
        let bundle = Bundle.main
        
        // Try to get the language bundle path directly
        if let path = bundle.path(forResource: languageCode, ofType: "lproj") {
            if let langBundle = Bundle(path: path) {
                let localized = NSLocalizedString(key, bundle: langBundle, comment: "")
                if localized != key {
                    return localized
                }
            } else {
                print("❌ Could not create bundle from path: \(path)")
            }
        } else {
            print("❌ No .lproj folder found for language: \(languageCode)")
        }
        // Fallback: Return the key itself
        print("⚠️ No translation found for '\(key)' in language '\(languageCode)'")
        return key
    }
}

