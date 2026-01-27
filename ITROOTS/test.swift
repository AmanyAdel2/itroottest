//
//  test.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//



import SwiftUI

struct DebugStorageView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔍 STORAGE DEBUG")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        // Login Status
                        Text("Login Status:")
                            .font(.headline)
                        
                        Text("AppState.isLoggedIn: \(appState.isLoggedIn ? "✅ TRUE" : "❌ FALSE")")
                            .foregroundColor(appState.isLoggedIn ? .green : .red)
                        
                        Text("Storage.isLoggedIn: \(StorageService.shared.isUserLoggedIn ? "✅ TRUE" : "❌ FALSE")")
                            .foregroundColor(StorageService.shared.isUserLoggedIn ? .green : .red)
                        
                        Divider()
                        
                        // Current User
                        Text("Current User:")
                            .font(.headline)
                        
                        if let user = StorageService.shared.getCurrentUser() {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("✅ User Found")
                                    .foregroundColor(.green)
                                
                                Text("Email: \(user.email)")
                                Text("Password: \(user.password)")
                                Text("Full Name: \(user.fullName)")
                                Text("Phone: \(user.phone)")
                                Text("ID: \(user.id)")
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Text("❌ No User Found")
                                .foregroundColor(.red)
                        }
                        
                        Divider()
                        
                        // All Users
                        Text("All Users:")
                            .font(.headline)
                        
                        let allUsers = StorageService.shared.getAllUsers()
                        Text("Total: \(allUsers.count) users")
                        
                        ForEach(allUsers, id: \.id) { user in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("• \(user.email)")
                                    .font(.caption)
                                Text("  Pass: \(user.password) | \(user.fullName)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            
            // Buttons
            VStack(spacing: 10) {
                Button("Print Storage Details") {
                    StorageService.shared.printAllUserDefaults()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Create Test User") {
                    createTestUser()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Clear All Data") {
                    clearAllData()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            print("\n🎯 DebugStorageView appeared")
            StorageService.shared.printAllUserDefaults()
        }
    }
    
    private func createTestUser() {
        let testUser = User(
            email: "test@test.com",
            phone: "01012345678",
            fullName: "Test User",
            password: "123456"
        )
        
        StorageService.shared.saveCurrentUser(testUser)
        print("✅ Test user created and saved")
        
        // Force reload
        DispatchQueue.main.async {
            appState.objectWillChange.send()
        }
    }
    
    private func clearAllData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        print("🧹 All UserDefaults cleared!")
        
        // Force reload
        DispatchQueue.main.async {
            appState.isLoggedIn = false
        }
    }
}




import SwiftUI

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: String = "en"
    @Published var locale: Locale = Locale(identifier: "en")
    
    private init() {
        loadSavedLanguage()
    }
    
    private func loadSavedLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language") {
            currentLanguage = savedLanguage
        } else {
            // Get system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = systemLanguage
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
        }
        
        updateLocale()
        UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func toggleLanguage() {
        let newLanguage = currentLanguage == "en" ? "ar" : "en"
        setLanguage(newLanguage)
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        updateLocale()
        
        // Save preferences
        UserDefaults.standard.set(languageCode, forKey: "app_language")
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Notify
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func updateLocale() {
        locale = Locale(identifier: currentLanguage)
    }
    
    var layoutDirection: LayoutDirection {
        currentLanguage == "ar" ? .rightToLeft : .leftToRight
    }
    
    // ADD THIS METHOD
    func localizedString(for key: String) -> String {
        // First try to get from specific bundle
        if let bundlePath = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            let value = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
            
            // If value is same as key, it might not be localized
            if value != key {
                return value
            }
        }
        
        // Fallback to NSLocalizedString
        return NSLocalizedString(key, comment: "")
    }
}
