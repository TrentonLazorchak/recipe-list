//
//  RecipesManager.swift
//  RecipeList
//
//  Created by Trenton Lazorchak on 5/30/25.
//

import Foundation

/// Protocol for managing requests to fetch recipes
protocol RecipesManaging {
    /// Used to get all recipes
    /// - Parameter useCache: Whether or not to use the cache on fetch
    /// - Returns: The recipe response returned
    func getAllRecipes(useCache: Bool) async throws -> RecipeResponse
}

/// Implementation of RecipesManaging that fetches responses from cloudfront.net
final class RecipesManager: RecipesManaging {

    /// URL for the all recipes network request
    private static let allRecipesURLString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"

    /// Cache storage
    var cache: [String: CachedResponse] = [:]

    /// Cache expiration time (in seconds)
    private static let cacheExpirationInterval: TimeInterval = 60 * 60 // 60 minutes

    /// Data structure to store cached data with timestamp
    struct CachedResponse {
        let data: Data
        let timestamp: Date
    }

    func getAllRecipes(useCache: Bool) async throws -> RecipeResponse {
        // Check if the recipe response is stored in cache and not expired
        let cacheKey = Self.allRecipesURLString
        if useCache,
           let cachedData = try await getCachedData(forKey: cacheKey) {
            // Return cached response
            return try JSONDecoder().decode(RecipeResponse.self, from: cachedData)
        }

        // Unwrap url
        guard let url = URL(string: Self.allRecipesURLString) else {
            assertionFailure("Invalid URL for all recipes")
            throw URLError(.badURL)
        }

        // Fetch recipes and decode json
        let (data, _) = try await URLSession.shared.data(from: url)
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)

        // Cache response if not empty
        if !recipeResponse.recipes.isEmpty {
            try await cacheData(recipeResponse, forKey: cacheKey)
        }

        return recipeResponse
    }

    /// Retrieve cached data if exists and not past the timeout
    func getCachedData(forKey key: String) async throws -> Data? {
        guard let cachedResponse = cache[key],
              Date().timeIntervalSince(cachedResponse.timestamp) < Self.cacheExpirationInterval else {
            return nil
        }

        return cachedResponse.data
    }

    /// Store data in the cache. Converts the passed in data to Json before storing
    func cacheData<T: Encodable>(_ data: T, forKey key: String) async throws {
        let encodedData = try JSONEncoder().encode(data)
        cache[key] = CachedResponse(data: encodedData, timestamp: Date())
    }

}
