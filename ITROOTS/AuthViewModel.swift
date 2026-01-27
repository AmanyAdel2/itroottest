//
//  AuthViewModel.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import Foundation


@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var emailError: String?
    @Published var phoneError: String?
    @Published var passwordError: String?
    @Published var nameError: String?
    @Published var confirmPasswordError: String?
    
    private let authService = AuthService.shared
    
    // MARK: - Validation
    func validateLogin() -> Bool {
        resetErrors()
        var isValid = true
        
        if email.isEmpty {
            emailError = NSLocalizedString("email_required", comment: "") // استخدم NSLocalizedString
            isValid = false
        } else if !isValidEmail(email) {
            emailError = NSLocalizedString("invalid_email", comment: "")
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = NSLocalizedString("password_required", comment: "")
            isValid = false
        } else if password.count < 6 {
            passwordError = NSLocalizedString("password_min_length", comment: "")
            isValid = false
        }
        
        return isValid
    }
    
    func validateRegistration() -> Bool {
        resetErrors()
        var isValid = true
        
        // Full Name validation
        if fullName.isEmpty {
            nameError = NSLocalizedString("name_required", comment: "")
            isValid = false
        } else if fullName.count < 2 {
            nameError = "Name must be at least 2 characters"
            isValid = false
        }
        
        // Email validation
        if email.isEmpty {
            emailError = NSLocalizedString("email_required", comment: "")
            isValid = false
        } else if !isValidEmail(email) {
            emailError = NSLocalizedString("invalid_email", comment: "")
            isValid = false
        } else if authService.isEmailExists(email) {
            emailError = "Email already registered"
            isValid = false
        }
        
        // Phone validation
        if phone.isEmpty {
            phoneError = NSLocalizedString("phone_required", comment: "")
            isValid = false
        } else if !isValidPhone(phone) {
            phoneError = "Please enter a valid phone number"
            isValid = false
        } else if authService.isPhoneExists(phone) {
            phoneError = "Phone number already registered"
            isValid = false
        }
        
        // Password validation
        if password.isEmpty {
            passwordError = NSLocalizedString("password_required", comment: "")
            isValid = false
        } else if password.count < 6 {
            passwordError = NSLocalizedString("password_min_length", comment: "")
            isValid = false
        }
        
        // Confirm Password validation
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = NSLocalizedString("passwords_dont_match", comment: "")
            isValid = false
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let cleanedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanedPhone.count >= 10
    }
    
    private func resetErrors() {
        emailError = nil
        phoneError = nil
        passwordError = nil
        nameError = nil
        confirmPasswordError = nil
    }
    
    // MARK: - Actions
    func login() async -> Bool {
        guard validateLogin() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.login(email: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = NSLocalizedString("invalid_credentials", comment: "")
            isLoading = false
            return false
        }
    }
    
    func register() async -> Bool {
        guard validateRegistration() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.register(
                email: email,
                phone: phone,
                fullName: fullName,
                password: password
            )
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func clearForm() {
        email = ""
        phone = ""
        password = ""
        fullName = ""
        confirmPassword = ""
        resetErrors()
    }
}
 


import Foundation

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
    private let storage = StorageService.shared
    
    private init() {
        loadCurrentUser()
        print("🚀 AuthService initialized")
        print("👤 Current user: \(currentUser?.email ?? "None")")
        print("🔐 Login status: \(isLoggedIn)")
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        print("🔐 Attempting login for: \(email)")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let allUsers = storage.getAllUsers()
        print("📋 Total users in storage: \(allUsers.count)")
        
        // عرض كل المستخدمين للتصحيح
        for user in allUsers {
            print("👤 User: \(user.email) - Password: \(user.password)")
        }
        
        guard let user = allUsers.first(where: {
            $0.email.lowercased() == email.lowercased()
        }) else {
            print("❌ User not found with email: \(email)")
            throw NSError(domain: "Auth", code: 401,
                         userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        print("✅ User found: \(user.email)")
        print("🔑 Checking password...")
        print("   Input: \(password)")
        print("   Stored: \(user.password)")
        
        if password == user.password {
            print("✅ Password correct!")
            
            // تحديث الحالة
            currentUser = user
            isLoggedIn = true
            
            // حفظ في Storage
            storage.saveCurrentUser(user)
            
            print("🎉 Login successful!")
            print("💾 Saved to storage: \(storage.isUserLoggedIn)")
        } else {
            print("❌ Password incorrect!")
            throw NSError(domain: "Auth", code: 401,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
        }
    }
    
    // MARK: - Registration
    func register(email: String, phone: String, fullName: String, password: String) async throws {
        print("👤 Attempting registration for: \(email)")
        
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Check if email exists
        if isEmailExists(email) {
            throw NSError(domain: "Auth", code: 400,
                         userInfo: [NSLocalizedDescriptionKey: "Email already registered"])
        }
        
        // Check if phone exists
        if isPhoneExists(phone) {
            throw NSError(domain: "Auth", code: 400,
                         userInfo: [NSLocalizedDescriptionKey: "Phone number already registered"])
        }
        
        // Create new user مع password
        let newUser = User(
            email: email,
            phone: phone,
            fullName: fullName,
            password: password
        )
        
        print("✅ New user created with password: \(password)")
        
        // Save user to storage
        storage.saveUser(newUser)
        print("💾 User saved to all users list")
        
        // Set as current user
        currentUser = newUser
        isLoggedIn = true
        storage.saveCurrentUser(newUser)
        print("💾 Current user saved to storage")
        
        print("🎉 Registration successful!")
        print("📊 Storage status after registration: \(storage.isUserLoggedIn)")
    }
    
    // MARK: - Logout
    func logout() {
        print("🚪 Logging out user: \(currentUser?.email ?? "Unknown")")
        
        currentUser = nil
        isLoggedIn = false
        
        // حذف من Storage
        storage.deleteCurrentUser()
        
        print("✅ Logged out successfully")
        print("📊 Storage status after logout: \(storage.isUserLoggedIn)")
    }
    
    // MARK: - Validation Helpers
    func isEmailExists(_ email: String) -> Bool {
        let allUsers = storage.getAllUsers()
        return allUsers.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    func isPhoneExists(_ phone: String) -> Bool {
        let allUsers = storage.getAllUsers()
        return allUsers.contains { $0.phone == phone }
    }
    
    // MARK: - User Persistence
    private func loadCurrentUser() {
        // تحميل من Storage
        currentUser = storage.getCurrentUser()
        isLoggedIn = storage.isUserLoggedIn
        
        print("📂 Loaded from storage:")
        print("   User: \(currentUser?.email ?? "None")")
        print("   Login status: \(isLoggedIn)")
        print("   Storage says: \(storage.isUserLoggedIn)")
        
        if let user = currentUser {
            print("   User details:")
            print("     - Email: \(user.email)")
            print("     - Name: \(user.fullName)")
            print("     - Password: \(user.password)")
        }
    }
}
/* storage service*/
import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys: String {
        case currentUser
        case isLoggedIn
        case allUsers
        case cachedPosts
        case cacheTimestamp
        case language
        case darkMode
    }
    
    // MARK: - User Management
    func saveCurrentUser(_ user: User) {
        print("\n💾 === SAVING CURRENT USER ===")
        print("User email: \(user.email)")
        print("User password: \(user.password)")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            
            defaults.set(data, forKey: Keys.currentUser.rawValue)
            defaults.set(true, forKey: Keys.isLoggedIn.rawValue)
            
            // Force save immediately
            defaults.synchronize()
            
            print("✅ Saved to keys:")
            print("   \(Keys.currentUser.rawValue): \(data.count) bytes")
            print("   \(Keys.isLoggedIn.rawValue): true")
            
            // Verify the save
            let saved = defaults.bool(forKey: Keys.isLoggedIn.rawValue)
            print("📋 Verification - isLoggedIn: \(saved)")
            
            if let savedData = defaults.data(forKey: Keys.currentUser.rawValue),
               let savedUser = try? JSONDecoder().decode(User.self, from: savedData) {
                print("📋 Verification - User email: \(savedUser.email)")
                print("📋 Verification - User password: \(savedUser.password)")
            }
            
            print("=== END SAVE ===\n")
            
        } catch {
            print("❌ Error saving user: \(error)")
        }
    }
    
    func getCurrentUser() -> User? {
        print("\n📖 === GETTING CURRENT USER ===")
        
        guard let data = defaults.data(forKey: Keys.currentUser.rawValue) else {
            print("❌ No data found for key: \(Keys.currentUser.rawValue)")
            
            // Check all keys for debugging
            print("🔍 Checking all keys in UserDefaults:")
            let allKeys = defaults.dictionaryRepresentation().keys
            for key in allKeys.sorted() {
                if key.contains("User") || key.contains("user") || key.contains("login") {
                    print("   \(key): \(defaults.object(forKey: key) ?? "nil")")
                }
            }
            
            print("=== END GET (No User) ===\n")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: data)
            
            print("✅ User found:")
            print("   Email: \(user.email)")
            print("   Password: \(user.password)")
            print("   Full name: \(user.fullName)")
            print("   Phone: \(user.phone)")
            print("   ID: \(user.id)")
            
            print("=== END GET (User Found) ===\n")
            return user
            
        } catch {
            print("❌ Error decoding user: \(error)")
            print("=== END GET (Error) ===\n")
            return nil
        }
    }
    
    func deleteCurrentUser() {
        print("\n🗑️ === DELETING CURRENT USER ===")
        
        defaults.removeObject(forKey: Keys.currentUser.rawValue)
        defaults.set(false, forKey: Keys.isLoggedIn.rawValue)
        defaults.synchronize()
        
        print("✅ User deleted")
        print("=== END DELETE ===\n")
    }
    
    var isUserLoggedIn: Bool {
        let status = defaults.bool(forKey: Keys.isLoggedIn.rawValue)
        print("🔐 isUserLoggedIn check: \(status)")
        return status
    }
    
    // MARK: - All Users Management
    func saveUser(_ user: User) {
        var allUsers = getAllUsers()
        allUsers.append(user)
        
        print("\n👥 === SAVING TO ALL USERS ===")
        print("Adding user: \(user.email)")
        print("Total users now: \(allUsers.count)")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allUsers)
            defaults.set(data, forKey: Keys.allUsers.rawValue)
            
            // Show all users for debugging
            print("📋 All users list:")
            for (index, user) in allUsers.enumerated() {
                print("   \(index + 1). \(user.email) - \(user.password)")
            }
            
            print("=== END SAVE ALL USERS ===\n")
            
        } catch {
            print("❌ Error saving all users: \(error)")
        }
    }
    
    func getAllUsers() -> [User] {
        guard let data = defaults.data(forKey: Keys.allUsers.rawValue) else {
            print("📭 No allUsers data found")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let users = try decoder.decode([User].self, from: data)
            return users
        } catch {
            print("❌ Error decoding all users: \(error)")
            return []
        }
    }
    
    // MARK: - Posts Cache
    func savePosts(_ posts: [Post]) {
        if let encoded = try? JSONEncoder().encode(posts) {
            defaults.set(encoded, forKey: Keys.cachedPosts.rawValue)
            defaults.set(Date(), forKey: Keys.cacheTimestamp.rawValue)
            defaults.synchronize()
        }
    }
    
    func getCachedPosts() -> [Post]? {
        guard let data = defaults.data(forKey: Keys.cachedPosts.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode([Post].self, from: data)
    }
    
    func isCacheValid() -> Bool {
        guard let timestamp = defaults.object(forKey: Keys.cacheTimestamp.rawValue) as? Date else {
            return false
        }
        return Date().timeIntervalSince(timestamp) < 3600 // 1 hour
    }
    
    // MARK: - Settings
    func saveLanguage(_ languageCode: String) {
        defaults.set(languageCode, forKey: Keys.language.rawValue)
        defaults.synchronize()
        
        // Update app language
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        print("🌐 Language saved: \(languageCode)")
    }
    
    func getLanguage() -> String {
        let lang = defaults.string(forKey: Keys.language.rawValue) ?? "en"
        print("🌐 Language loaded: \(lang)")
        return lang
    }
    
    func saveDarkMode(_ isDark: Bool) {
        defaults.set(isDark, forKey: Keys.darkMode.rawValue)
        defaults.synchronize()
    }
    
    func getDarkMode() -> Bool {
        defaults.bool(forKey: Keys.darkMode.rawValue)
    }
    
    // MARK: - Debug Helper
    func printAllUserDefaults() {
        print("\n" + String(repeating: "=", count: 50))
        print("📊 USERDEFAULTS DUMP")
        print(String(repeating: "=", count: 50))
        
        let allKeys = defaults.dictionaryRepresentation().keys.sorted()
        
        for key in allKeys {
            if let value = defaults.object(forKey: key) {
                if key.contains("User") || key.contains("user") ||
                   key.contains("login") || key.contains("Logged") {
                    print("🔑 \(key): \(value)")
                }
            }
        }
        
        print(String(repeating: "=", count: 50) + "\n")
    }
}
import Foundation

extension String {
    var localized: String {
        // استخدام Bundle الحالي للغة المختارة
        if let localization = LocalizationService.shared as? LocalizationService,
           let bundlePath = Bundle.main.path(forResource: localization.currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return bundle.localizedString(forKey: self, value: nil, table: "Localizable")
        }
        
        // Fallback إلى NSLocalizedString العادي
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let format = self.localized
        return String(format: format, arguments: arguments)
    }
}

/* settings view model*/
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currentLanguage: String = "en"
    @Published var isDarkMode: Bool = false
    @Published var currentUser: User?
    
    init() {
        loadSettings()
        loadCurrentUser()
        setupLanguageObserver()
    }
    
    private func loadSettings() {
        currentLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        isDarkMode = UserDefaults.standard.bool(forKey: "dark_mode")
    }
    
    private func loadCurrentUser() {
        // Load from your auth service
        // currentUser = AuthService.shared.currentUser
    }
    
    private func setupLanguageObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LanguageChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let language = notification.userInfo?["language"] as? String {
                self?.currentLanguage = language
                print("🔔 Language change observed in SettingsViewModel: \(language)")
            }
        }
    }
    
    func toggleLanguage() {
        LocalizationService.shared.toggleLanguage()
        currentLanguage = LocalizationService.shared.currentLanguage
    }
    
    func toggleDarkMode() {
        let newValue = !isDarkMode
        UserDefaults.standard.set(newValue, forKey: "dark_mode")
        isDarkMode = newValue
        
        // Apply dark mode immediately
        applyDarkMode(newValue)
    }
    
    private func applyDarkMode(_ isDark: Bool) {
        // Get all connected scenes
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = isDark ? .dark : .light
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
/*postt vm*/


@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline = false
    
    private let networkService = NetworkService.shared
    
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        
        let fetchedPosts = await networkService.getPosts()
        
        await MainActor.run {
            self.posts = fetchedPosts
            self.isLoading = false
            self.isOffline = !networkService.isConnected
            
            if fetchedPosts.isEmpty && self.isOffline {
                self.errorMessage = "No internet connection. Showing cached data."
            }
        }
    }
    
    func refreshPosts() async {
        guard networkService.isConnected else {
            errorMessage = "No internet connection"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let refreshedPosts = await networkService.refreshPosts()
        
        await MainActor.run {
            self.posts = refreshedPosts
            self.isLoading = false
            self.isOffline = false
        }
    }
}
/*home vm*/
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var featuredItems: [FeaturedItem] = []
    @Published var verticalItems: [VerticalItem] = []
    
    init() {
        loadStaticData()
    }
    
    private func loadStaticData() {
        // Horizontal scroll items
        featuredItems = [
            FeaturedItem(id: 1, title: "Featured 1", color: .blue),
            FeaturedItem(id: 2, title: "Featured 2", color: .green),
            FeaturedItem(id: 3, title: "Featured 3", color: .orange),
            FeaturedItem(id: 4, title: "Featured 4", color: .purple),
            FeaturedItem(id: 5, title: "Featured 5", color: .pink)
        ]
        
        // Vertical scroll items
        verticalItems = (1...20).map { index in
            VerticalItem(
                id: index,
                title: "Item \(index)",
                subtitle: "Description for item \(index)",
                icon: "number.circle.fill"
            )
        }
    }
}

struct FeaturedItem: Identifiable {
    let id: Int
    let title: String
    let color: Color
}

struct VerticalItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
}
/*app state*/
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        isLoggedIn = AuthService.shared.currentUser != nil
    }
}
/*erro*/
enum AuthError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordsDontMatch
    case emailExists
    case phoneExists
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return NSLocalizedString("invalid_email", comment: "")
        case .invalidPassword:
            return NSLocalizedString("password_min_length", comment: "")
        case .passwordsDontMatch:
            return NSLocalizedString("passwords_dont_match", comment: "")
        case .emailExists:
            return "Email already registered"
        case .phoneExists:
            return "Phone number already registered"
        case .invalidCredentials:
            return NSLocalizedString("invalid_credentials", comment: "")
        }
    }
}

/*network*/
import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    var isConnected: Bool {
        true // Simple check for demo
    }
    
    private let storage = StorageService.shared
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    // MARK: - Fetch Posts
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw URLError(.badURL)
        }
        
        // Check cache first
        if storage.isCacheValid(), let cachedPosts = storage.getCachedPosts() {
            return cachedPosts
        }
        
        // Fetch from network
        let (data, _) = try await URLSession.shared.data(from: url)
        let posts = try JSONDecoder().decode([Post].self, from: data)
        
        // Save to cache
        storage.savePosts(posts)
        
        return posts
    }
    
    // MARK: - Get Posts (Main method)
    func getPosts() async -> [Post] {
        do {
            if isConnected {
                let posts = try await fetchPosts()
                return posts
            } else {
                // Return cached posts if offline
                return storage.getCachedPosts() ?? []
            }
        } catch {
            print("Error fetching posts: \(error)")
            return storage.getCachedPosts() ?? []
        }
    }
    
    func refreshPosts() async -> [Post] {
        do {
            let posts = try await fetchPosts()
            return posts
        } catch {
            print("Error refreshing posts: \(error)")
            return storage.getCachedPosts() ?? []
        }
    }
}
//

