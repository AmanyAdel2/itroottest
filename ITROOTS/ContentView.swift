//
//  ContentView.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localization: LocalizationService
    @State private var showDebug = false
    
    var body: some View {
        Group {
            if appState.isLoading {
                SplashScreen()
            } else if appState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environment(\.locale, localization.locale)
        .environment(\.layoutDirection, localization.layoutDirection)
        .onAppear {
            print("\n" + String(repeating: "📱", count: 25))
            print("CONTENTVIEW APPEARED")
            print(String(repeating: "📱", count: 25))
            
            print("AppState.isLoggedIn: \(appState.isLoggedIn)")
            print("Storage.isLoggedIn: \(StorageService.shared.isUserLoggedIn)")
            
            if let user = StorageService.shared.getCurrentUser() {
                print("👤 Current User: \(user.email)")
            }
            
            print("\n")
        }
        .sheet(isPresented: $showDebug) {
            DebugStorageView()
                .environmentObject(appState)
        }
        .onTapGesture(count: 3) {
            print("👆 Triple tap detected - showing debug")
            showDebug = true
        }
    }
}

struct SplashScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Checking Login...")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            ProgressView()
                .padding(.top, 30)
            
            Text("Tap screen 3 times for debug")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
/*debug*/
import SwiftUI

struct LocalizationDebugView: View {
    @EnvironmentObject var localization: LocalizationService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🌍 Localization Debug")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Current Language: \(localization.currentLanguage)")
                Text("Layout Direction: \(localization.layoutDirection == .leftToRight ? "LTR" : "RTL")")
                Text("Locale: \(localization.locale.identifier)")
                
                Text("\nTest Strings:")
                    .font(.headline)
                
                Text("English: \(NSLocalizedString("welcome", comment: ""))")
                Text("Arabic: \(NSLocalizedString("welcome", comment: "")) - Should show مرحباً")
                
                Text("\nDirect Test:")
                    .font(.headline)
                
                Text("Using NSLocalizedString: \(NSLocalizedString("sign_in", comment: ""))")
                Text("Using AppStrings: \(AppStrings.signIn)")
                
                // Test bundle path
                if let bundlePath = Bundle.main.path(forResource: localization.currentLanguage, ofType: "lproj") {
                    Text("Bundle Path: \(bundlePath)")
                } else {
                    Text("⚠️ Bundle not found for: \(localization.currentLanguage)")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Toggle Language") {
                localization.toggleLanguage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Force Reload Bundle") {
                forceBundleReload()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func forceBundleReload() {
        // Clear bundle cache
        UserDefaults.standard.set([localization.currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force UI update
        localization.objectWillChange.send()
        
        print("🔄 Forced bundle reload for: \(localization.currentLanguage)")
    }
}

