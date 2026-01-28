//
//  LoginView.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localization: LocalizationService
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Language Toggle Button
                    HStack {
                        Spacer()
                        Button {
                            localization.toggleLanguage()
                            print("🌐 Toggled to: \(localization.currentLanguage)")
                            print("📖 Test translation: \(NSLocalizedString("welcome", comment: ""))")
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                Text(localization.currentLanguage == "en" ? AppStrings.arabic : AppStrings.english)
                            }
                            .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(AppStrings.welcomeBack)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(AppStrings.signInToContinue)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField(AppStrings.email, text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.emailError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.password)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField(AppStrings.password, text: $viewModel.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.passwordError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Forgot Password
                        Button(AppStrings.forgotPassword) {
                            // Handle forgot password
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 30)
                    
                    // Login Button
                    Button {
                        Task {
                            if await viewModel.login() {
                                // Update login state
                                appState.isLoggedIn = true // ← FIX HERE
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(AppStrings.signIn)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .disabled(viewModel.isLoading)
                    
                    // Register Link
                    HStack {
                        Text(AppStrings.dontHaveAccount)
                            .foregroundColor(.gray)
                        
                        Button(AppStrings.signUp) {
                            showRegister = true
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .padding(.top, 10)
                    
                    // Debug info
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Debug Info:")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("Current Lang: \(localization.currentLanguage)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("AppState isLoggedIn: \(appState.isLoggedIn ? "YES" : "NO")")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(localization)
                .environmentObject(appState) // Pass appState to RegisterView
        }
    }
}
/*          register     */
struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState // ← Add this
    @EnvironmentObject var localization: LocalizationService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text(AppStrings.createAccount)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(AppStrings.joinOurCommunity)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Registration Form
                    VStack(spacing: 15) {
                        // Full Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.fullName)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField(AppStrings.fullName, text: $viewModel.fullName)
                                .textInputAutocapitalization(.words)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.nameError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField(AppStrings.email, text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.emailError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Phone Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.phone)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField(AppStrings.phone, text: $viewModel.phone)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.phoneError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.password)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField(AppStrings.password, text: $viewModel.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.passwordError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.confirmPassword)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField(AppStrings.confirmPassword, text: $viewModel.confirmPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            if let error = viewModel.confirmPasswordError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Terms Agreement
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    // Register Button
                    Button {
                        Task {
                            if await viewModel.register() {
                                // Update login state
                                appState.isLoggedIn = true // ← FIX HERE
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(AppStrings.createAccount)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .disabled(viewModel.isLoading)
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 30)
                    }
                    
                    // Login Link
                    HStack {
                        Text(AppStrings.alreadyHaveAccount)
                            .foregroundColor(.gray)
                        
                        Button(AppStrings.signIn) {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .padding(.top, 10)
                    
                    // Debug Info
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Debug Info:")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("Current Lang: \(localization.currentLanguage)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("AppState isLoggedIn: \(appState.isLoggedIn ? "YES" : "NO")")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AppState())
            .environmentObject(LocalizationService.shared)
    }
}



/* main tab */


struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "bag.fill")
                }
        }
    }
}
/* home view*/


struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localization: LocalizationService
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    
    // Horizontal scroll items
    let featuredItems = [
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"
    ]
    
    // Vertical scroll items
    let verticalItems = Array(1...20).map { "Vertical Item \($0)" }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Horizontal Scroll Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Featured Items")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(featuredItems, id: \.self) { item in
                                    FeaturedCard(title: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Vertical Scroll Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("All Items")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(verticalItems, id: \.self) { item in
                                VerticalCard(title: item)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(localization)
        }
    }
}

struct FeaturedCard: View {
    let title: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 150, height: 100)
                .overlay(
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.blue)
                )
        }
    }
}

struct VerticalCard: View {
    let title: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Text(title)
                .font(.body)
                .padding(.leading, 10)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
/* post view*/

//struct PostsView: View {
//    @StateObject private var viewModel = PostsViewModel()
//    @EnvironmentObject var localization: LocalizationService
//    
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    VStack {
//                        ProgressView()
//                        Text("Loading posts...")
//                            .foregroundColor(.gray)
//                            .padding(.top)
//                    }
//                } else if viewModel.posts.isEmpty {
//                    VStack(spacing: 20) {
//                        Image(systemName: "wifi.slash")
//                            .font(.system(size: 60))
//                            .foregroundColor(.gray)
//                        
//                        Text("No posts available")
//                            .font(.title2)
//                            .foregroundColor(.gray)
//                        
//                        if viewModel.isOffline {
//                            Text("You're offline. Please check your internet connection.")
//                                .font(.caption)
//                                .foregroundColor(.orange)
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//                    }
//                } else {
//                    List(viewModel.posts) { post in
//                        PostRow(post: post)
//                    }
//                    .refreshable {
//                        await viewModel.refreshPosts()
//                    }
//                }
//            }
//            .navigationTitle("Posts")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        Task {
//                            await viewModel.refreshPosts()
//                        }
//                    } label: {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                    .disabled(viewModel.isLoading)
//                }
//            }
//        }
//        .onAppear {
//            Task {
//                await viewModel.loadPosts()
//            }
//        }
//    }
//}

//struct PostRow: View {
//    let post: Post
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(post.title)
//                .font(.headline)
//                .lineLimit(2)
//            
//            Text(post.body)
//                .font(.body)
//                .foregroundColor(.gray)
//                .lineLimit(3)
//            
//            HStack {
//                Text("Post ID: \(post.id)")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                
//                Spacer()
//                
//                Text("User: \(post.userId)")
//                    .font(.caption)
//                    .foregroundColor(.green)
//            }
//            .padding(.top, 5)
//        }
//        .padding(.vertical, 8)
//    }
//}
/*settings view*/
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localization: LocalizationService
    @AppStorage("dark_mode") private var isDarkMode: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var refreshID = UUID()
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // App Settings Section
                Section(header: Text("app_settings".localized)) {
                    // Language Setting
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("language".localized)
                                .font(.body)
                            
                            Text(currentLanguageDisplay)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            // Toggle language
                            localization.toggleLanguage()
                            forceRefresh()
                        } label: {
                            Text(localization.currentLanguage == "en" ? "العربية" : "English")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    
                    // Dark Mode Toggle
                    HStack {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        
                        Text("dark_mode".localized)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .onChange(of: isDarkMode) { newValue in
                                applyDarkMode(newValue)
                            }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(.systemBackground))
                
                // Account Section
                Section(header: Text("account".localized)) {
                    // Current User Info
                    if let user = AuthService.shared.currentUser {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("logged_in_as".localized)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text(user.fullName)
                                        .font(.headline)
                                    
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if !user.phone.isEmpty {
                                        Text(user.phone)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                    // Logout Button
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("sign_out".localized)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color(.systemBackground))
                
                // About Section
                Section(header: Text("about".localized)) {
                    // App Version
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        
                        Text("app_version".localized)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    
                    // Privacy Policy
                    Button {
                        // Open privacy policy
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("privacy_policy".localized)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    // Terms of Service
                    Button {
                        // Open terms of service
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("terms_of_service".localized)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color(.systemBackground))
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("sign_out".localized, isPresented: $showLogoutAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("confirm_logout".localized, role: .destructive) {
                    performLogout()
                }
            } message: {
                Text("logout_confirmation".localized)
            }
        }
        .id(refreshID)
        .environment(\.locale, localization.locale)
        .environment(\.layoutDirection, localization.layoutDirection)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            forceRefresh()
        }
        .onAppear {
            // Initialize dark mode from saved setting
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
    // Computed property for language display
    private var currentLanguageDisplay: String {
        switch localization.currentLanguage {
        case "en":
            return "English"
        case "ar":
            return "العربية"
        default:
            return localization.currentLanguage
        }
    }
    
    // Force view refresh
    private func forceRefresh() {
        refreshID = UUID()
        print("🔄 SettingsView refreshed")
    }
    
    // Apply dark mode
    private func applyDarkMode(_ isDark: Bool) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = isDark ? .dark : .light
                }
            }
        }
    }
    
    // Perform logout
    private func performLogout() {
        print("🚪 Starting logout process...")
        
        // 1. Clear auth service
        AuthService.shared.logout()
        
        // 2. Update app state
        appState.isLoggedIn = false
        
        // 3. Clear any cached data
        UserDefaults.standard.removeObject(forKey: "user_token")
        UserDefaults.standard.synchronize()
        
        // 4. Dismiss settings
        dismiss()
        
        print("✅ Logout completed successfully")
    }
}
