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





class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: String = "en"
    @Published var layoutDirection: LayoutDirection = .leftToRight
    @Published var locale: Locale = Locale(identifier: "en")
    
    private let storage = StorageService.shared
    
    private init() {
        loadSavedLanguage()
        print("🚀 LocalizationService initialized")
        print("📖 Initial language: \(currentLanguage)")
    }
    
    private func loadSavedLanguage() {
        let savedLanguage = storage.getLanguage()
        currentLanguage = savedLanguage
        updateLayoutDirection()
        updateLocale()
        print("📂 Loaded saved language: \(savedLanguage)")
    }
    
    func toggleLanguage() {
        let newLanguage = currentLanguage == "en" ? "ar" : "en"
        setLanguage(newLanguage)
    }
    
    func setLanguage(_ languageCode: String) {
        print("🔄 Setting language to: \(languageCode)")
        
        // 1. تحديث المتغيرات
        currentLanguage = languageCode
        storage.saveLanguage(languageCode)
        
        // 2. تحديث Layout Direction
        updateLayoutDirection()
        
        // 3. تحديث Locale
        updateLocale()
        
        // 4. تحديث إعدادات اللغة في UserDefaults
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 5. إعادة تحميل Bundle (الطريقة الصحيحة)
        forceBundleReload()
        
        // 6. إشعار النظام
        NotificationCenter.default.post(name: .languageChanged, object: nil)
        
        // 7. تحديث الـ UI
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        print("✅ Language changed to: \(languageCode)")
        print("🧭 Layout direction: \(layoutDirection == .leftToRight ? "LTR" : "RTL")")
        print("🌍 Locale: \(locale.identifier)")
    }
    
    private func updateLayoutDirection() {
        let newDirection: LayoutDirection = currentLanguage == "ar" ? .rightToLeft : .leftToRight
        if layoutDirection != newDirection {
            layoutDirection = newDirection
            print("🧭 Layout direction updated to: \(newDirection == .leftToRight ? "LTR" : "RTL")")
        }
    }
    
    private func updateLocale() {
        let newLocale = Locale(identifier: currentLanguage)
        if locale.identifier != newLocale.identifier {
            locale = newLocale
            print("🌍 Locale updated to: \(newLocale.identifier)")
        }
    }
    
    private func forceBundleReload() {
        // الطريقة الصحيحة لإعادة تحميل Bundle
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            print("📦 Bundle found at: \(path)")
            
            // اختبار Bundle
            let testString = bundle.localizedString(forKey: "welcome", value: nil, table: "Localizable")
            print("🔤 Bundle test translation: \(testString)")
            
            // إعادة تعيين Bundle الرئيسي (للتطبيقات المستقبلية)
            // Note: لا يمكن تغيير Bundle.main مباشرة في iOS
            // بدلاً من ذلك، سنستخدم NSLocalizedString مع bundle محدد
        } else {
            print("⚠️ Bundle NOT found for: \(currentLanguage)")
            print("📦 Available bundles: \(Bundle.main.localizations)")
        }
    }
    
    // دالة مساعدة للحصول على نص مترجم من bundle معين
    func localizedString(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        }
        return NSLocalizedString(key, comment: "")
    }
    
    var isRTL: Bool {
        currentLanguage == "ar"
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
//🔧 إصلاح مشكلة: التطبيق لا يتذكر Login عند إعادة التشغيل
//
//المشكلة في StorageService! دعني أصلحه لك:


