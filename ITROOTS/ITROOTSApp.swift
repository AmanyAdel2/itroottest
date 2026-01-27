//
//  ITROOTSApp.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var localization = LocalizationService.shared
    
    init() {
        // اختبار ملفات Localization
        LocalizationFileChecker.checkLocalizationFiles()
        LocalizationFileChecker.testAllTranslations()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
                .environment(\.layoutDirection, localization.layoutDirection)
                .onAppear {
                    // اختبار AppStrings
                    AppStrings.debugLocalization()
                }
        }
    }
}
