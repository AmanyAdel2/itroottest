//
//  User.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let email: String
    let phone: String
    let fullName: String
    let password: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         email: String,
         phone: String,
         fullName: String,
         password: String) {
        self.id = id
        self.email = email
        self.phone = phone
        self.fullName = fullName
        self.password = password
        self.createdAt = Date()
    }
}
struct Post: Codable, Identifiable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
import Foundation

enum AppStrings {
    // MARK: - Helper Function (الطريقة الآمنة)
    static func localized(_ key: String) -> String {
        // أولاً: حاول استخدام Bundle الحالي
        if let localization = LocalizationService.shared as? LocalizationService {
            return localization.localizedString(for: key)
        }
        
        // ثانياً: Fallback إلى الطريقة العادية
        return NSLocalizedString(key, comment: "")
    }
    
    // MARK: - Common
    static var welcome: String { localized("welcome") }
    static var signIn: String { localized("sign_in") }
    static var signUp: String { localized("sign_up") }
    static var signOut: String { localized("sign_out") }
    
    // MARK: - Login & Register
    static var email: String { localized("email") }
    static var password: String { localized("password") }
    static var phone: String { localized("phone") }
    static var fullName: String { localized("full_name") }
    static var confirmPassword: String { localized("confirm_password") }
    static var createAccount: String { localized("create_account") }
    static var dontHaveAccount: String { localized("dont_have_account") }
    static var alreadyHaveAccount: String { localized("already_have_account") }
    static var forgotPassword: String { localized("forgot_password") }
    static var orContinueWith: String { localized("or_continue_with") }
    static var joinOurCommunity: String { localized("join_our_community") }
    static var signInToContinue: String { localized("sign_in_to_continue") }
    static var welcomeBack: String { localized("welcome_back") }
    
    // MARK: - Validation
    static var emailRequired: String { localized("email_required") }
    static var invalidEmail: String { localized("invalid_email") }
    static var passwordRequired: String { localized("password_required") }
    static var passwordMinLength: String { localized("password_min_length") }
    static var nameRequired: String { localized("name_required") }
    static var passwordsDontMatch: String { localized("passwords_dont_match") }
    static var phoneRequired: String { localized("phone_required") }
    
    // MARK: - Navigation
    static var home: String { localized("home") }
    static var settings: String { localized("settings") }
    static var language: String { localized("language") }
    static var english: String { localized("english") }
    static var arabic: String { localized("arabic") }
    static var darkMode: String { localized("dark_mode") }
    static var cancel: String { localized("cancel") }
    static var done: String { localized("done") }
    
    // MARK: - Debug Helper
    static func debugLocalization() {
        print("\n🔍 DEBUG LOCALIZATION STRINGS 🔍")
        print("Current Language: \(LocalizationService.shared.currentLanguage)")
        print("Welcome: \(welcome)")
        print("Sign In: \(signIn)")
        print("Sign Up: \(signUp)")
        print("Home: \(home)")
        print("Settings: \(settings)")
        print("🔍 END DEBUG 🔍\n")
    }
}



import Foundation

class LocalizationFileChecker {
    static func checkLocalizationFiles() {
        print("🔍 CHECKING LOCALIZATION FILES 🔍")
        
        // 1. التحقق من وجود المجلدات
        let fileManager = FileManager.default
        
        // 2. البحث في Bundle الرئيسي
        if let bundlePath = Bundle.main.bundlePath as NSString? {
            let enPath = bundlePath.appendingPathComponent("en.lproj")
            let arPath = bundlePath.appendingPathComponent("ar.lproj")
            
            print("📁 English path: \(enPath)")
            print("📁 Arabic path: \(arPath)")
            
            // 3. التحقق من وجود المجلدات
            let enExists = fileManager.fileExists(atPath: enPath)
            let arExists = fileManager.fileExists(atPath: arPath)
            
            print("✅ English folder exists: \(enExists)")
            print("✅ Arabic folder exists: \(arExists)")
            
            // 4. التحقق من وجود ملف Localizable.strings
            if enExists {
                let enStringsPath = (enPath as NSString).appendingPathComponent("Localizable.strings")
                let enFileExists = fileManager.fileExists(atPath: enStringsPath)
                print("📄 English strings file exists: \(enFileExists)")
                
                if enFileExists {
                    do {
                        let content = try String(contentsOfFile: enStringsPath, encoding: .utf8)
                        print("📝 English file has content: \(!content.isEmpty)")
                        print("📏 English file size: \(content.count) characters")
                    } catch {
                        print("⚠️ Error reading English file: \(error)")
                    }
                }
            }
            
            if arExists {
                let arStringsPath = (arPath as NSString).appendingPathComponent("Localizable.strings")
                let arFileExists = fileManager.fileExists(atPath: arStringsPath)
                print("📄 Arabic strings file exists: \(arFileExists)")
                
                if arFileExists {
                    do {
                        let content = try String(contentsOfFile: arStringsPath, encoding: .utf8)
                        print("📝 Arabic file has content: \(!content.isEmpty)")
                        print("📏 Arabic file size: \(content.count) characters")
                        
                        // اختبار سريع للنصوص العربية
                        if content.contains("مرحباً") {
                            print("🎉 Arabic text 'مرحباً' found!")
                        }
                    } catch {
                        print("⚠️ Error reading Arabic file: \(error)")
                    }
                }
            }
        }
        
        // 5. عرض اللغات المتاحة
        print("\n🌐 Available localizations in Bundle: \(Bundle.main.localizations)")
        
        print("🔍 END CHECK 🔍")
    }
    
    static func testAllTranslations() {
        print("\n🎯 TESTING ALL TRANSLATIONS 🎯")
        
        let testKeys = [
            "welcome", "sign_in", "sign_up", "email", "password",
            "home", "settings", "create_account", "full_name"
        ]
        
        for key in testKeys {
            let translation = NSLocalizedString(key, comment: "")
            print("\(key): \(translation)")
        }
        
        print("🎯 END TEST 🎯")
    }
}
