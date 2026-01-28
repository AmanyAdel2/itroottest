//
//  products.swift
//  ITROOTS
//
//  Created by Macos on 27/01/2026.
//

import Foundation
struct Product : Codable , Identifiable{
    let id: Int
        let title: String
        let description: String
        let price: Double
    let brand: String?
       let category: String
       let thumbnail: String
}
struct ProductResponse :Codable{
    let products : [Product]
}
import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let storage = StorageService.shared
    private let baseURL = "https://dummyjson.com"
    
    // MARK: - Check Network Connectivity
    var isConnected: Bool {
        // Simple check - in production use NetworkReachability
        return true
    }
    
    // MARK: - Fetch Products from Network
    func fetchProducts() async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/products") else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ProductResponse.self, from: data)
            
            // Save to cache
            storage.saveProducts(response.products)
            
            return response.products
        } catch {
            print("❌ Network error: \(error)")
            throw error
        }
    }
    
    // MARK: - Get Products (with offline support)
    func getProducts() async -> [Product] {
        print("📱 Getting products...")
        
        // Check cache first if offline
        if !isConnected {
            print("📡 Device is offline")
            if let cachedProducts = storage.getCachedProducts() {
                print("📦 Returning cached products: \(cachedProducts.count)")
                return cachedProducts
            }
            print("📭 No cached products available")
            return getMockProducts()
        }
        
        // Check if cache is still valid (less than 1 hour old)
       
        
        // Fetch from network
        do {
            let products = try await fetchProducts()
            print("✅ Fetched \(products.count) products from API")
            return products
        } catch {
            print("⚠️ API failed, checking cache: \(error)")
            
            // Fallback to cache if network fails
            if let cachedProducts = storage.getCachedProducts() {
                print("📦 Falling back to cached: \(cachedProducts.count)")
                return cachedProducts
            }
            
            // Last resort: mock data
            print("📝 Using mock data")
            return getMockProducts()
        }
    }
    
    // MARK: - Force Refresh (ignore cache)
    func refreshProducts() async -> [Product] {
        print("🔄 Force refreshing products...")
        
        if !isConnected {
            print("📡 Cannot refresh - offline")
            if let cachedProducts = storage.getCachedProducts() {
                return cachedProducts
            }
            return getMockProducts()
        }
        
        do {
            let products = try await fetchProducts()
            return products
        } catch {
            print("⚠️ Refresh failed: \(error)")
            if let cachedProducts = storage.getCachedProducts() {
                return cachedProducts
            }
            return getMockProducts()
        }
    }
    private func getMockProducts() -> [Product] {
            return [
                Product(
                    id: 1,
                    title: "iPhone 15",
                    description: "Latest smartphone",
                    price: 999.99,
                    brand: "Apple",
                    category: "smartphones",
                    thumbnail: "https://cdn.dummyjson.com/product-images/1/thumbnail.jpg"
                ),
                Product(
                    id: 2,
                    title: "MacBook Pro",
                    description: "Powerful laptop",
                    price: 1999.99,
                    brand: "Apple",
                    category: "laptops",
                    thumbnail: "https://cdn.dummyjson.com/product-images/6/thumbnail.png"
                ),
                Product(
                    id: 3,
                    title: "Samsung Galaxy",
                    description: "Android smartphone",
                    price: 799.99,
                    brand: "Samsung",
                    category: "smartphones",
                    thumbnail: "https://cdn.dummyjson.com/product-images/3/thumbnail.jpg"
                )
            ]
        }
        
        // MARK: - Test Connection
        func testConnection() async -> Bool {
            guard let url = URL(string: "https://www.apple.com") else {
                return false
            }
            
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse {
                    return (200...299).contains(httpResponse.statusCode)
                }
                return false
            } catch {
                return false
            }
        }
    
}
import SwiftUI
import SwiftUI

@MainActor
class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline = false
    @Published var lastUpdated: Date?
    
    private let networkService = NetworkService.shared
    private let storage = StorageService.shared
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        // Check connection
        isOffline = !(await networkService.testConnection())
        
        let fetchedProducts = await networkService.getProducts()
        
        products = fetchedProducts
        lastUpdated = Date()
        isLoading = false
        
        if products.isEmpty {
            errorMessage = "No products available"
        }
        
        print("📊 Loaded \(products.count) products, Offline: \(isOffline)")
    }
    
    func refreshProducts() async {
        let refreshedProducts = await networkService.refreshProducts()
        
        await MainActor.run {
            products = refreshedProducts
            lastUpdated = Date()
            isOffline = false
        }
    }
    
    
}
import SwiftUI

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Offline indicator
                if viewModel.isOffline {
                    OfflineBanner()
                }
                
                // Last updated indicator
                if let lastUpdated = viewModel.lastUpdated {
                    LastUpdatedView(lastUpdated: lastUpdated)
                }
                
                // Products list
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if viewModel.products.isEmpty {
                        EmptyView(message: viewModel.errorMessage ?? "No products found")
                    } else {
                        ProductsListView(products: viewModel.products)
                    }
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RefreshButton(viewModel: viewModel)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    CacheInfoButton(viewModel: viewModel)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadProducts()
                }
            }
            .refreshable {
                await viewModel.refreshProducts()
            }
        }
    }
}

// MARK: - Supporting Views

struct OfflineBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text("You're offline - showing cached data")
                .font(.caption)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.2))
        .foregroundColor(.orange)
    }
}

struct LastUpdatedView: View {
    let lastUpdated: Date
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
            Text("Updated: \(lastUpdated, style: .time)")
                .font(.caption2)
        }
        .padding(4)
        .foregroundColor(.gray)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading products...")
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

struct EmptyView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

struct ProductsListView: View {
    let products: [Product]
    
    var body: some View {
        List(products) { product in
            ProductRow(product: product)
        }
    }
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.category.capitalized)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(String(format: "$%.2f", product.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RefreshButton: View {
    @ObservedObject var viewModel: ProductsViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.refreshProducts()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
        .disabled(viewModel.isLoading)
    }
}

struct CacheInfoButton: View {
    @ObservedObject var viewModel: ProductsViewModel
    @State private var showingCacheAlert = false
    
    var body: some View {
        Button {
            showingCacheAlert = true
        } label: {
            Image(systemName: "info.circle")
        }
        .alert("Cache Info", isPresented: $showingCacheAlert) {
           
            Button("OK", role: .cancel) { }
        } message: {
            Text("Products cached: \(viewModel.products.count)\nOffline: \(viewModel.isOffline ? "Yes" : "No")")
        }
    }
}
struct OfflineTestView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var simulateOffline = false
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Simulate Offline", isOn: $simulateOffline)
                .padding()
            
            Button("Load Products") {
                Task {
                    await viewModel.loadProducts()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Force Refresh") {
                Task {
                    await viewModel.refreshProducts()
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
           
            
            VStack {
                Text("Status:")
                    .font(.headline)
                Text("Loaded: \(viewModel.products.count) products")
                Text("Offline: \(viewModel.isOffline ? "Yes" : "No")")
                Text("Loading: \(viewModel.isLoading ? "Yes" : "No")")
                
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated: \(lastUpdated, style: .time)")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Show first product
            if let product = viewModel.products.first {
                VStack(alignment: .leading) {
                    Text("First Product:")
                        .font(.headline)
                    Text("\(product.title)")
                    Text("$\(product.price, specifier: "%.2f")")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .onChange(of: simulateOffline) { newValue in
            // In a real app, you would simulate network changes here
            print("Simulate offline: \(newValue)")
        }
        .onAppear {
            Task {
                await viewModel.loadProducts()
            }
        }
    }
}

