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
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isLoggedIn {
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(localization)
                } else {
                    LoginView()
                        .environmentObject(appState)
                        .environmentObject(localization)
                }
            }
            .environment(\.locale, localization.locale)
            .environment(\.layoutDirection, localization.layoutDirection)
            .onAppear {
                appState.checkLoginStatus()
            }
        }
    }
}
//
//    private func applyDarkMode(_ isDark: Bool) {
//        DispatchQueue.main.async {
//            for scene in UIApplication.shared.connectedScenes {
//                if let windowScene = scene as? UIWindowScene {
//                    for window in windowScene.windows {
//                        window.overrideUserInterfaceStyle = isDark ? .dark : .light
//                    }
//                }
//            }
//        }
//    }
//}
